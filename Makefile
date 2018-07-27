all: serve

build:
	    mkdocs build

serve:
	    mkdocs serve

release:
	    ./bin/release.sh

