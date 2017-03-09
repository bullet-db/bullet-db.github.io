# bullet-docs

This hosts the documentation source and examples for [Bullet](https://github.com/yahoo/bullet-storm).

The built documentation can be accessed [here](https://yahoo.github.io/bullet-docs).

## Building the documentation

You need [mkdocs](http://www.mkdocs.org/#installation) installed to build the documentation.

This also uses the mkdocs theme : [Cinder](http://sourcefoundry.org/cinder/).

Since Cinder has not been upgraded in a while, you will need to bring in changes in this [PR](https://github.com/chrissimpkins/cinder/pull/26) of Cinder found here: [twardoch/clinker-mktheme](https://github.com/twardoch/clinker-mktheme/tree/2016-12-22)

You will need Python installed.

```bash
sudo pip install virtualenv
virtualenv mkdocs
source mkdocs/bin/activate
pip install mkdocs-cinder
pip install git+git://github.com/twardoch/clinker-mktheme.git@2016-12-22 --upgrade
git clone git@github.com:yahoo/bullet-docs.git
cd bullet-docs
mkdocs build
```

## Building the examples

You will need [Maven 3](https://maven.apache.org/install.html) and [JDK 8](http://www.oracle.com/technetwork/java/javase/downloads/index.html) installed to build the examples.

```bash
cd bullet-docs/examples/storm && mvn package
```

Code licensed under the Apache 2 license. See LICENSE file for terms.
