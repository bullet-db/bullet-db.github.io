/*
 *  Copyright 2018, Oath Inc.
 *  Licensed under the terms of the Apache License, Version 2.0.
 *  See the LICENSE file associated with the project for terms.
 */
package com.yahoo.bullet.spark.examples.receiver

import java.util.UUID

import scala.collection.JavaConverters._
import scala.util.Random

import com.yahoo.bullet.record.BulletRecord
import com.yahoo.bullet.spark.utils.{BulletSparkConfig, BulletSparkLogger}
import org.apache.spark.storage.StorageLevel
import org.apache.spark.streaming.receiver.Receiver


object RandomReceiver {
  // Fields in BulletRecord
  private val STRING = "uuid"
  private val LONG = "tuple_number"
  private val DOUBLE = "probability"
  private val BOOLEAN_MAP = "tags"
  private val STATS_MAP = "stats"
  private val LIST = "classifiers"
  private val DURATION = "duration"
  private val TYPE = "type"
  private val RANDOM_MAP_KEY_A = "field_A"
  private val RANDOM_MAP_KEY_B = "field_B"
  private val PERIOD_COUNT = "period_count"
  private val RECORD_NUMBER = "record_number"
  private val NANO_TIME = "nano_time"
  private val TIMESTAMP = "timestamp"
  // Some static values in BulletRecord for the fields
  private val STRING_POOL = Array("foo", "bar", "baz", "qux", "quux", "norf")
  private val INTEGER_POOL = Array(2057, 13, 10051, 2, 1059, 187)
}

/**
 * Constructor that takes a configuration to use.
 *
 * @param config The BulletSparkConfig to load settings from.
 */
class RandomReceiver(val config: BulletSparkConfig)
  extends Receiver[BulletRecord](StorageLevel.MEMORY_AND_DISK_SER) with BulletSparkLogger {
  // Number of tuples to emit
  private val maxPerPeriod = 100L
  // Period in milliseconds. Default 1000 ms
  private val period = 1000
  private var periodCount = 0L
  private var generatedThisPeriod = 0L
  private var nextIntervalStart = 0L

  override def onStart(): Unit = {
    new Thread() {
      override def run(): Unit = {
        receive()
      }
    }.start()
    logger.info("Random receiver started.")
  }

  override def onStop(): Unit = {
    logger.info("Random receiver stopped.")
  }

  private def receive(): Unit = {
    nextIntervalStart = System.currentTimeMillis()
    while (!isStopped) {
      val timeNow = System.currentTimeMillis()
      // Only emit if we are still in the interval and haven't gone over our per period max
      if (timeNow <= nextIntervalStart && generatedThisPeriod < maxPerPeriod) {
        store(generateRecord())
        generatedThisPeriod += 1
      }
      if (timeNow > nextIntervalStart) {
        logger.info("Generated {} tuples out of {}", generatedThisPeriod, maxPerPeriod)
        nextIntervalStart = timeNow + period
        generatedThisPeriod = 0
        periodCount += 1
      }
      // It is courteous to sleep for a short time.
      try {
        Thread.sleep(1)
      } catch {
        case e: InterruptedException => logger.error("Error: ", e)
      }
    }
  }

  private def generateRecord(): BulletRecord = {
    val record = new BulletRecord()
    val uuid = UUID.randomUUID().toString
    record.setString(RandomReceiver.STRING, uuid)
    record.setLong(RandomReceiver.LONG, generatedThisPeriod)
    record.setDouble(RandomReceiver.DOUBLE, Random.nextDouble())
    record.setString(RandomReceiver.TYPE, RandomReceiver.STRING_POOL(Random.nextInt(RandomReceiver.STRING_POOL.length)))
    record.setLong(RandomReceiver.DURATION, System.nanoTime() % RandomReceiver.INTEGER_POOL(Random.nextInt(RandomReceiver.INTEGER_POOL.length)))
    val booleanMap = Map[java.lang.String, java.lang.Boolean](
      uuid.substring(0, 8) -> Random.nextBoolean(),
      uuid.substring(9, 13) -> Random.nextBoolean(),
      uuid.substring(14, 18) -> Random.nextBoolean(),
      uuid.substring(19, 23) -> Random.nextBoolean()
    )
    record.setBooleanMap(RandomReceiver.BOOLEAN_MAP, booleanMap.asJava)
    val statsMap = Map[java.lang.String, java.lang.Long](
      RandomReceiver.PERIOD_COUNT -> periodCount,
      RandomReceiver.RECORD_NUMBER -> (periodCount * maxPerPeriod + generatedThisPeriod),
      RandomReceiver.NANO_TIME -> System.nanoTime(),
      RandomReceiver.TIMESTAMP -> System.nanoTime()
    )
    record.setLongMap(RandomReceiver.STATS_MAP, statsMap.asJava)
    val randomMapA = Map[java.lang.String, java.lang.String](
      RandomReceiver.RANDOM_MAP_KEY_A -> RandomReceiver.STRING_POOL(Random.nextInt(RandomReceiver.STRING_POOL.length)),
      RandomReceiver.RANDOM_MAP_KEY_B -> RandomReceiver.STRING_POOL(Random.nextInt(RandomReceiver.STRING_POOL.length))
    )
    val randomMapB = Map[java.lang.String, java.lang.String](
      RandomReceiver.RANDOM_MAP_KEY_A -> RandomReceiver.STRING_POOL(Random.nextInt(RandomReceiver.STRING_POOL.length)),
      RandomReceiver.RANDOM_MAP_KEY_B -> RandomReceiver.STRING_POOL(Random.nextInt(RandomReceiver.STRING_POOL.length))
    )
    record.setListOfStringMap(RandomReceiver.LIST, List(randomMapA.asJava, randomMapB.asJava).asJava)
    record
  }
}

