# bullet-docs

This hosts the documentation source and examples for [Bullet](https://github.com/yahoo/bullet-storm).

The built documentation can be accessed [here](https://bullet-db.github.io).

## Installing mkdocs

You will need Python installed.

You can install the required tool "mkdocs" like this (a "mkdocs" directory will be created wherever you execute these commands):

```bash
sudo pip install virtualenv
virtualenv mkdocs
source mkdocs/bin/activate
pip install mkdocs==0.16.3 
pip install mkdocs-cinder
pip install git+git://github.com/twardoch/clinker-mktheme.git@master --upgrade
```

The above commands will install [mkdocs](http://www.mkdocs.org/#installation) along with the mkdocs theme : [Cinder](http://sourcefoundry.org/cinder/).

Since Cinder has not been upgraded in a while, it uses the changes in this [PR](https://github.com/chrissimpkins/cinder/pull/26) of Cinder found here: [twardoch/clinker-mktheme](https://github.com/twardoch/clinker-mktheme/tree/master).

## JavaDocs are Added When Releasing

**Note:** If you build and serve the site locally you will not be able to see the JavaDocs, you will only see simple place-holder pages (these are required or mkdocs will complain). The JavaDocs are added during the release process.

Running `make release` will save the docs currently in the master branch, and then replace the place-holder pages with the docs currently on master.

**To add new JavaDocs:**
* In src branch:
    * Create new folder for the docs. e.g. `mkdir -p docs/java-docs/bullet-core/0.4.3/`
    * Create a place-holder file. e.g. `cp docs/java-docs/bullet-core/0.4.2/index.html docs/java-docs/bullet-core/0.4.3/`
    * Update mkdocs.yml - add a new line for the new sub-folder - see "JavaDocs" section of mkdocs.yml
    * Commit these changes to the src branch. e.g. `git add -A && git commit -m "Added new JavaDocs"`
    * Push src branch to remote
* Build a release: `make release` - this will leave you in the master branch with a new build ready NOT including the new docs you want to add
* In master branch after doing "make release" BEFORE pushing to remote:
    * Create new folder for the docs. e.g.: `mkdir -p java-docs/bullet-core/0.4.3`
    * Copy the contents of the new JavaDocs into the new folder. e.g. `cp -r ~/PATH-TO-NEW-DOCS/bullet-core/target/site/apidocs/* java-docs/bullet-core/0.4.3/`
    * Commit these changes to the master branch. e.g. `git add -A && git commit -m "Build at abc123 with new JavaDocs"`
    * Push master branch to remote

## Building the Documentation

While mkdocs is available:

`make build` will build the documentation.

`make serve` will serve the documentation so it can be viewed from a local browser.

`make release` will build a release and commit it to your local "master" branch. This command assumes you have a clean git environment ("git diff" prints nothing). It will build the documentation and commit it to your local master branch. **YOU must push the changes** in your master branch to the remote repo if you want to publish the changes after the command completes successfully.

## Building the examples

You will need [Maven 3](https://maven.apache.org/install.html) and [JDK 8](http://www.oracle.com/technetwork/java/javase/downloads/index.html) installed to build the examples.

```bash
cd bullet-docs/examples/ && make
```

Code licensed under the Apache 2 license. See LICENSE file for terms.
