all: clean build

clean:
	rm -rf examples_artifacts.tar.gz bullet-examples
	cd storm && mvn clean

build:
	mkdir -p bullet-examples/storm
	mkdir -p bullet-examples/web-service
	mkdir -p bullet-examples/ui
	cp install-all.sh bullet-examples/
	cd storm && mvn package
	cp storm/target/*jar-with-dependencies.jar bullet-examples/storm
	cp storm/bin/launch.sh bullet-examples/storm
	cp storm/src/main/resources/bullet_settings.yaml bullet-examples/storm
	cp web-service/* bullet-examples/web-service
	cp ui/* bullet-examples/ui
	tar -czf examples_artifacts.tar.gz bullet-examples/*
	rm -rf bullet-examples


