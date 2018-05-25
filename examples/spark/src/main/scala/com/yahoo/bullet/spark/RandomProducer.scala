/*
 *  Copyright 2018, Oath Inc.
 *  Licensed under the terms of the Apache License, Version 2.0.
 *  See the LICENSE file associated with the project for terms.
 */
package com.yahoo.bullet.spark

import com.yahoo.bullet.record.BulletRecord
import com.yahoo.bullet.spark.receiver.RandomReceiver
import com.yahoo.bullet.spark.utils.BulletSparkConfig
import org.apache.spark.streaming.StreamingContext
import org.apache.spark.streaming.dstream.DStream

class RandomProducer extends DataProducer {
  override def getBulletRecordStream(ssc: StreamingContext, config: BulletSparkConfig): DStream[BulletRecord] = {
    // Bullet record input stream.
    val bulletReceiver = new RandomReceiver(config)
    ssc.receiverStream(bulletReceiver).asInstanceOf[DStream[BulletRecord]]
  }
}

