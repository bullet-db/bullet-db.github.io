#! /bin/bash

# We pass 20 and 100 to the RandomSpout, which means it generates up to 20 random records every 100 ms.
storm jar bullet-storm-example-1.0.0-SNAPSHOT-jar-with-dependencies.jar \
          com.yahoo.bullet.storm.Topology \
          --bullet-conf ./bullet_settings.yaml \
          --bullet-spout com.yahoo.bullet.storm.examples.RandomSpout \
          -c topology.acker.executors=1 \
          -c topology.max.spout.pending=1000 \
          -c topology.backpressure.enable=false
