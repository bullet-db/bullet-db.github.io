all: clean build

clean:
	rm -rf examples_artifacts.tar.gz bullet-examples
	cd storm && mvn clean
	cd spark && mvn clean

build-storm:
	mkdir -p bullet-examples/backend/storm
	cp install-all-storm.sh bullet-examples/
	cd storm && mvn package
	cp storm/target/*jar-with-dependencies.jar bullet-examples/backend/storm
	cp storm/bin/launch.sh bullet-examples/backend/storm
	cp storm/src/main/resources/bullet_settings.yaml bullet-examples/backend/storm

build-spark:
	mkdir -p bullet-examples/backend/spark
	cp install-all-spark.sh bullet-examples/
	cd spark && mvn package
	cp spark/target/bullet-spark-example-*-SNAPSHOT.jar bullet-examples/backend/spark/bullet-spark-example.jar
	cp spark/src/main/resources/bullet_spark_kafka_settings.yaml bullet-examples/backend/spark

build-web-service:
	mkdir -p bullet-examples/web-service
	cp web-service/* bullet-examples/web-service

build-ui:
	mkdir -p bullet-examples/ui
	cp ui/* bullet-examples/ui

archive:
	tar -czf examples_artifacts.tar.gz bullet-examples/*
	rm -rf bullet-examples

build: build-storm build-spark build-web-service build-ui archive

