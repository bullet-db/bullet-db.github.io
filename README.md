# bullet-docs

This hosts the documentation source and examples for [Bullet](https://github.com/yahoo/bullet-storm).

The built documentation can be accessed [here](https://yahoo.github.io/bullet-docs).

## Building the documentation

You will need Python installed.

```bash
sudo pip install virtualenv
virtualenv mkdocs
source mkdocs/bin/activate
pip install mkdocs==0.16.3 
pip install mkdocs-cinder
pip install git+git://github.com/twardoch/clinker-mktheme.git@master --upgrade
git clone git@github.com:yahoo/bullet-docs.git
cd bullet-docs
mkdocs serve
```

The above commands will install [mkdocs](http://www.mkdocs.org/#installation) along with the mkdocs theme : [Cinder](http://sourcefoundry.org/cinder/).

Since Cinder has not been upgraded in a while, it uses the changes in this [PR](https://github.com/chrissimpkins/cinder/pull/26) of Cinder found here: [twardoch/clinker-mktheme](https://github.com/twardoch/clinker-mktheme/tree/master).

## Building the examples

You will need [Maven 3](https://maven.apache.org/install.html) and [JDK 8](http://www.oracle.com/technetwork/java/javase/downloads/index.html) installed to build the examples.

```bash
cd bullet-docs/examples/ && make
```

Code licensed under the Apache 2 license. See LICENSE file for terms.
