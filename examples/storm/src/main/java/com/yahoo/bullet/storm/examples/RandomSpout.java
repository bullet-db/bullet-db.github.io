/*
 *  Copyright 2017, Yahoo Inc.
 *  Licensed under the terms of the Apache License, Version 2.0.
 *  See the LICENSE file associated with the project for terms.
 */
package com.yahoo.bullet.storm.examples;

import com.yahoo.bullet.common.BulletConfig;
import com.yahoo.bullet.record.AvroBulletRecord;
import com.yahoo.bullet.record.BulletRecord;
import lombok.extern.slf4j.Slf4j;
import org.apache.storm.spout.SpoutOutputCollector;
import org.apache.storm.task.TopologyContext;
import org.apache.storm.topology.OutputFieldsDeclarer;
import org.apache.storm.topology.base.BaseRichSpout;
import org.apache.storm.tuple.Fields;
import org.apache.storm.tuple.Values;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.UUID;

import static java.util.Arrays.asList;

/**
 * This spout does not read from a source of data and convert it to {@link BulletRecord}. It instead generates
 * random data. You can pass in how many tuples to generate per period and the length of a period as arguments.
 */
@Slf4j
public class RandomSpout extends BaseRichSpout {
    protected SpoutOutputCollector outputCollector;

    public static final String RECORD_FIELD = "record";
    // This is the message ID for all tuples. This enables acking from this Spout to the FilterBolt. However
    // this spout does not handle dealing with failures. So, we use this as a way to simply enable acking.
    public static final Long DUMMY_ID = 42L;

    public static final int MS_TO_NS = 1000000;
    // Number of tuples to emit
    private int maxPerPeriod = 100;
    // Period in nanoseconds. Default 1000 ms
    private int period = 1000 * MS_TO_NS;

    private Random random;
    private long periodCount = 0;
    private int generatedThisPeriod = 0;
    private long nextIntervalStart = 0;

    // Fields in BulletRecord
    public static final String STRING = "uuid";
    public static final String LONG = "tuple_number";
    public static final String DOUBLE = "probability";
    public static final String GAUSSIAN = "gaussian";
    public static final String BOOLEAN_MAP = "tags";
    public static final String STATS_MAP = "stats";
    public static final String LIST = "classifiers";
    public static final String DURATION = "duration";
    public static final String TYPE = "type";
    public static final String SUBTYPES_MAP = "subtypes";

    public static final String RANDOM_MAP_KEY_A = "field_A";
    public static final String RANDOM_MAP_KEY_B = "field_B";

    public static final String PERIOD_COUNT = "period_count";
    public static final String RECORD_NUMBER = "record_number";
    public static final String NANO_TIME = "nano_time";
    public static final String TIMESTAMP = "timestamp";

    // Some static values in BulletRecord for the fields
    public static final String[] STRING_POOL = { "foo", "bar", "baz", "qux", "quux", "norf" };
    public static final Integer[] INTEGER_POOL = { 2057, 13, 10051, 2, 1059, 187 };

    /**
     * @param args A List of Strings for your Spout. This example takes a number of messages to emit before sleeping and the amount
     *             of time in ns to sleep for.
     * @throws IOException if the {@link BulletConfig} cannot be created.
     */
    public RandomSpout(List<String> args) {
        if (args != null && args.size() >= 2) {
            maxPerPeriod = Integer.valueOf(args.get(0));
            period = Integer.valueOf(args.get(1)) * MS_TO_NS;

            // If less than 1 tuple per period , change it to 1
            if (maxPerPeriod < 1) {
                maxPerPeriod = 1;
            }
            // If less than 10 ms, change it to 10
            if (period < 10000000) {
                period = 10000000;
            }
        }
    }

    @Override
    public void declareOutputFields(OutputFieldsDeclarer declarer) {
        declarer.declare(new Fields(RECORD_FIELD));
    }

    @Override
    public void open(Map conf, TopologyContext context, SpoutOutputCollector collector) {
        outputCollector = collector;
    }

    @Override
    public void activate() {
        random = new Random();
        nextIntervalStart = System.nanoTime();
        log.info("RandomSpout activated");
    }

    @Override
    public void deactivate() {
        log.info("RandomSpout deactivated");
    }

    @Override
    public void nextTuple() {
        long timeNow = System.nanoTime();
        // Only emit if we are still in the interval and haven't gone over our per period max
        if (timeNow <= nextIntervalStart && generatedThisPeriod < maxPerPeriod) {
            outputCollector.emit(new Values(generateRecord()), DUMMY_ID);
            generatedThisPeriod++;
            return;
        }
        if (timeNow > nextIntervalStart) {
            log.info("Generated {} tuples out of {}", generatedThisPeriod, maxPerPeriod);
            nextIntervalStart = timeNow + period;
            generatedThisPeriod = 0;
            periodCount++;
        }
        // It is courteous to sleep for a short time if you're not emitting anything...
        try {
            Thread.sleep(1);
        } catch (InterruptedException e) {
            log.error("Error: ", e);
        }
    }

    private Map<String, String> makeRandomMap() {
        Map<String, String> randomMap = new HashMap<>(2);
        randomMap.put(RANDOM_MAP_KEY_A, STRING_POOL[random.nextInt(STRING_POOL.length)]);
        randomMap.put(RANDOM_MAP_KEY_B, STRING_POOL[random.nextInt(STRING_POOL.length)]);
        return randomMap;
    }

    private BulletRecord generateRecord() {
        BulletRecord record = new AvroBulletRecord();
        String uuid = UUID.randomUUID().toString();

        record.setString(STRING, uuid);
        record.setLong(LONG, (long) generatedThisPeriod);
        record.setDouble(DOUBLE, random.nextDouble());
        record.setDouble(GAUSSIAN, random.nextGaussian());
        record.setString(TYPE, STRING_POOL[random.nextInt(STRING_POOL.length)]);
        record.setLong(DURATION, System.currentTimeMillis() % INTEGER_POOL[random.nextInt(INTEGER_POOL.length)]);

        record.setStringMap(SUBTYPES_MAP, makeRandomMap());

        Map<String, Boolean> booleanMap = new HashMap<>(4);
        booleanMap.put(uuid.substring(0, 8), random.nextBoolean());
        booleanMap.put(uuid.substring(9, 13), random.nextBoolean());
        booleanMap.put(uuid.substring(14, 18), random.nextBoolean());
        booleanMap.put(uuid.substring(19, 23), random.nextBoolean());
        record.setBooleanMap(BOOLEAN_MAP, booleanMap);

        Map<String, Long> statsMap = new HashMap<>(4);
        statsMap.put(PERIOD_COUNT, periodCount);
        statsMap.put(RECORD_NUMBER, periodCount * maxPerPeriod + generatedThisPeriod);
        statsMap.put(NANO_TIME, System.nanoTime());
        statsMap.put(TIMESTAMP, System.currentTimeMillis());
        record.setLongMap(STATS_MAP, statsMap);

        record.setListOfStringMap(LIST, asList(makeRandomMap(), makeRandomMap()));

        return record;
    }
}
