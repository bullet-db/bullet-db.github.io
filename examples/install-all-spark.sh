#! /usr/bin/env bash

set -euo pipefail

BULLET_EXAMPLES_VERSION=0.4.0
BULLET_UI_VERSION=0.4.0
BULLET_WS_VERSION=0.2.1
BULLET_KAFKA_VERSION=0.3.0
KAFKA_VERSION=0.11.0.1
SPARK_VERSION=2.2.1
NVM_VERSION=0.33.1
NODE_VERSION=6.9.4

KAFKA_TOPIC_REQUESTS=bullet.requests
KAFKA_TOPIC_RESPONSES=bullet.responses

println() {
    local DATE
    DATE="$(date)"
    printf "%s [BULLET-QUICKSTART] %s\n" "${DATE}" "$1"
}

print_versions() {
    println "Using the following artifacts..."
    println "Bullet Examples:    ${BULLET_EXAMPLES_VERSION}"
    println "Bullet Web Service: ${BULLET_WS_VERSION}"
    println "Bullet UI:          ${BULLET_UI_VERSION}"
    println "Kafka:              ${KAFKA_VERSION}"
    println "NVM:                ${NVM_VERSION}"
    println "Node.js:            ${NODE_VERSION}"
    println "Done!"
}

download() {
    local URL="$1"
    local FILE="$2"

    local FILE_PATH="${BULLET_DOWNLOADS}/${FILE}"

    if [[ -s "${FILE_PATH}" ]]; then
        println "Download exists in ${FILE_PATH}. Skipping download..."
    else
        println "curl --retry 2 -#LO \"${URL}/${FILE}\""
        cd "${BULLET_DOWNLOADS}" && { curl --retry 2 -#LO "${URL}/${FILE}" ; cd - &> /dev/null; }
    fi
}

export_vars() {
    local PWD
    PWD="$(pwd)"

    println "Exporting some variables..."
    export BULLET_HOME="${PWD}/bullet-quickstart"
    export BULLET_EXAMPLES=$BULLET_HOME/bullet-examples
    export BULLET_DOWNLOADS=$BULLET_HOME/bullet-downloads
    export BULLET_SPARK=${BULLET_HOME}/backend/spark
    println "Done!"
}

setup() {
    println "Setting up directories..."
    mkdir -p "${BULLET_HOME}/backend/spark"
    mkdir -p "${BULLET_HOME}/service"
    mkdir -p "${BULLET_HOME}/ui"
    mkdir -p "${BULLET_HOME}/pubsub"
    mkdir -p "${BULLET_DOWNLOADS}"
    println "Done!"
}

install_bullet_examples() {
    println "Downloading Bullet Examples ${BULLET_EXAMPLES_VERSION}..."
    download "https://github.com/yahoo/bullet-docs/releases/download/v${BULLET_EXAMPLES_VERSION}" "examples_artifacts.tar.gz"

    println "Installing Bullet Examples..."
    tar -xzf "${BULLET_DOWNLOADS}/examples_artifacts.tar.gz" -C "${BULLET_HOME}"
    println "Done!"
}

install_kafka() {
    local KAFKA="kafka_2.12-${KAFKA_VERSION}"
    local PUBSUB="${BULLET_HOME}/pubsub/"

    println "Downloading Kafka ${KAFKA_VERSION}..."
    download "https://archive.apache.org/dist/kafka/${KAFKA_VERSION}" "${KAFKA}.tgz"

    println "Installing Kafka ..."
    tar -xzf ${BULLET_DOWNLOADS}/${KAFKA}.tgz -C ${PUBSUB}
    export KAFKA_DIR=${PUBSUB}${KAFKA}

    println "Done!"
}

install_bullet_kafka() {
    local BULLET_KAFKA="bullet-kafka-${BULLET_KAFKA_VERSION}-fat.jar"
    local PUBSUB="${BULLET_HOME}/pubsub/"

    println "Downloading bullet-kafka ${BULLET_KAFKA_VERSION}..."
    download "http://jcenter.bintray.com/com/yahoo/bullet/bullet-kafka/${BULLET_KAFKA_VERSION}" "${BULLET_KAFKA}"
    cp ${BULLET_DOWNLOADS}/${BULLET_KAFKA} ${PUBSUB}${BULLET_KAFKA}
    export BULLET_KAFKA_JAR=${PUBSUB}${BULLET_KAFKA}

    println "Done!"
}

launch_kafka() {
    println "Launching Zookeeper..."
    $KAFKA_DIR/bin/zookeeper-server-start.sh $KAFKA_DIR/config/zookeeper.properties &
    sleep 3

    println "Launching Kafka..."
    $KAFKA_DIR/bin/kafka-server-start.sh $KAFKA_DIR/config/server.properties &

    sleep 3
    println "Done!"
}

create_topics() {
    set +e
    println "Creating kafka topics ${KAFKA_TOPIC_REQUESTS} and ${KAFKA_TOPIC_RESPONSES}..."
    $KAFKA_DIR/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic ${KAFKA_TOPIC_REQUESTS}
    $KAFKA_DIR/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic ${KAFKA_TOPIC_RESPONSES}
    set -e

    sleep 3
    println "Done!"
}

install_web_service() {
    local BULLET_WEB_SERVICE="bullet-service-${BULLET_WS_VERSION}-embedded.jar"

    println "Downloading bullet web service version ${BULLET_WS_VERSION}..."
    download "http://jcenter.bintray.com/com/yahoo/bullet/bullet-service/${BULLET_WS_VERSION}" "${BULLET_WEB_SERVICE}"

    println "Installing bullet web service..."
    cp ${BULLET_DOWNLOADS}/${BULLET_WEB_SERVICE} ${BULLET_HOME}/service/
    cp ${BULLET_EXAMPLES}/web-service/example_kafka_pubsub_config.yaml ${BULLET_HOME}/service/
    cp ${BULLET_EXAMPLES}/web-service/example_columns.json ${BULLET_HOME}/service/
    export BULLET_WS_JAR=${BULLET_HOME}/service/${BULLET_WEB_SERVICE}

    println "Done!"
}

launch_web_service() {
    local BULLET_SERVICE_HOME="${BULLET_HOME}/service"

    println "Launching Bullet Web Service..."
    cd "${BULLET_SERVICE_HOME}"
    java -Dloader.path=${BULLET_KAFKA_JAR} -jar ${BULLET_WS_JAR} \
        --bullet.pubsub.config=${BULLET_SERVICE_HOME}/example_kafka_pubsub_config.yaml \
        --bullet.schema.file=${BULLET_SERVICE_HOME}/example_columns.json \
        --server.port=9999  \
        --logging.path=. \
        --logging.file=log.txt &> log.txt &

    println "Sleeping for 15 s to ensure Bullet Web Service is up..."
    sleep 15

    println "Testing the Web Service: Getting column schema..."
    println ""
    curl -s http://localhost:9999/api/bullet/columns
    println "Finished Bullet Web Service test"
}

install_spark() {
    local SPARK="spark-${SPARK_VERSION}-bin-hadoop2.7.tgz"

    println "Downloading Spark version ${SPARK_VERSION}..."
    download "http://www-us.apache.org/dist/spark/spark-${SPARK_VERSION}" "${SPARK}"
        
    println "Installing Spark version ${SPARK_VERSION}..."
    cp ${BULLET_DOWNLOADS}/${SPARK} ${BULLET_HOME}/backend/spark/

    tar -xzf "${BULLET_HOME}/backend/spark/${SPARK}" -C "${BULLET_HOME}/backend/spark/"
    export SPARK_DIR="${BULLET_HOME}/backend/spark/spark-${SPARK_VERSION}-bin-hadoop2.7"

    println "Done!"
}

install_bullet_spark() {
    cp $BULLET_HOME/bullet-examples/backend/spark/* $BULLET_SPARK
    # Remove this 88 - THIS STILL NEEDS to be implemented - download the thing (it's not available online yet because we haven't released this version yet):
    # Something like this: curl -Lo bullet-spark.jar http://jcenter.bintray.com/com/yahoo/bullet/bullet-spark/0.1.1/bullet-spark-0.1.1-standalone.jar
}

launch_bullet_spark() {
    cd ${BULLET_SPARK}
    println "Launching bullet-spark..."
    ${SPARK_DIR}/bin/spark-submit \
        --master local[10]  \
        --class com.yahoo.bullet.spark.BulletSparkStreamingMain \
        --driver-class-path $BULLET_SPARK/bullet-spark.jar:${BULLET_KAFKA_JAR}:$BULLET_SPARK/bullet-spark-example.jar \
        $BULLET_SPARK/bullet-spark.jar \
        --bullet-spark-conf=$BULLET_SPARK/bullet_spark_settings.yaml &> log.txt &

    println "Sleeping for 15 s to ensure bullet-spark is up and running..."
    sleep 15

    println "Done! You should now be able to query Bullet through the web service. Try this:"
    println "curl -s -H 'Content-Type: text/plain' -X POST -d '{\"aggregation\": {\"size\": 1}}' http://localhost:9999/api/bullet/sse-query"
}



install_node() {
    # NVM unset var bug
    set +u

    println "Trying to install nvm. If there is a failure, manually perform: "
    println "    curl -s https://raw.githubusercontent.com/creationix/nvm/v${NVM_VERSION}/install.sh | bash"
    println "    nvm install v${NODE_VERSION}"
    println "    nvm use v${NODE_VERSION}"
    println "and then try this script again..."

    println "Downloading and installing NVM ${NVM_VERSION}..."
    curl --retry 2 -s "https://raw.githubusercontent.com/creationix/nvm/v${NVM_VERSION}/install.sh" | bash

    println "Loading nvm into current environment if installation successful..."
    [ -s "${HOME}/.nvm/nvm.sh" ] && source "${HOME}/.nvm/nvm.sh"
    println "Done!"

    println "Installing Node ${NODE_VERSION}..."
    nvm install "v${NODE_VERSION}"
    nvm use "v${NODE_VERSION}"

    set -u

    println "Done!"
}

launch_bullet_ui() {
    local BULLET_UI_ARCHIVE="bullet-ui-v${BULLET_UI_VERSION}.tar.gz"

    println "Downloading Bullet UI ${BULLET_UI_VERSION}..."
    download "https://github.com/yahoo/bullet-ui/releases/download/v${BULLET_UI_VERSION}" "${BULLET_UI_ARCHIVE}"

    cd "${BULLET_HOME}/ui"

    println "Installing Bullet UI..."
    tar -xzf "${BULLET_DOWNLOADS}/${BULLET_UI_ARCHIVE}"

    println "Configuring Bullet UI..."
    cp "${BULLET_EXAMPLES}/ui/env-settings.json" config/

    println "Launching Bullet UI..."
    PORT=8800 node express-server.js &

    println "Sleeping for 5 s to ensure Bullet UI is up..."
    sleep 5
    println "Done!"
}

cleanup() {
    set +e

    pkill -f "[e]xpress-server.js"
    pkill -f "[e]xample_kafka_pubsub_config.yaml"
    pkill -f "[b]ullet-spark"
    ${KAFKA_DIR}/bin/kafka-server-stop.sh
    ${KAFKA_DIR}/bin/zookeeper-server-stop.sh

    sleep 3

    rm -rf "${BULLET_EXAMPLES}" "${BULLET_HOME}/backend" "${BULLET_HOME}/service" \
           "${BULLET_HOME}/ui" "${BULLET_HOME}/pubsub" /tmp/dev-storm-zookeeper

    set -e
}

teardown() {
    println "Killing and cleaning up all Bullet components..."
    cleanup &> /dev/null
    println "Done!"
}

unset_all() {
    unset -f print_versions println download export_vars setup \
             install_bullet_examples \
             install_storm launch_storm launch_bullet_storm \
             launch_bullet_web_service \
             install_node launch_bullet_ui \
             cleanup teardown unset_all launch
}

launch() {
    print_versions
    export_vars

    teardown

    setup

    # install_bullet_examples
    # <------------- Remove this 88 - the above line needs to be uncommented and all the below stuff should be removed once this artifact actualy exists on the git cloud or whatever
    cp ~/bullet/bullet-db.github.io/examples/examples_artifacts.tar.gz ${BULLET_DOWNLOADS}/
    tar -xzf "${BULLET_DOWNLOADS}/examples_artifacts.tar.gz" -C "${BULLET_HOME}" # <------------ Remove this 88 - remove this line and the one above it once the artifact is actulaly on github

    install_kafka
    install_bullet_kafka
    launch_kafka
    create_topics

    install_web_service
    launch_web_service

    install_spark
    # install_bullet_spark
    # <------------- Remove this 88 - the above line needs to be uncommented and all the below stuff should be removed once this artifact actualy exists on the git cloud or whatever
    cp $BULLET_HOME/bullet-examples/backend/spark/* $BULLET_SPARK # <------------ Remove this 88
    cp ~/bullet/bullet-spark/target/bullet-spark-0.1.1-SNAPSHOT-standalone.jar $BULLET_SPARK/bullet-spark.jar # <------------ Remove this 88

    launch_bullet_spark

    # Remove this 88 - deal with the following two lines:
    # Now do the UI stuff once the new UI is ready
    # ALSO - DON'T FORGET! The teardown stuff doesn't work unless you run the whole script (the "else" block at the bottom won't work) because the KAFKA_DIR isn't defined unless you run install_kafka function) - so fix that somehow






    # install_node
    # launch_bullet_ui

    # println "All components launched! Visit http://localhost:8800 (default) for the UI"
    # unset_all
}

clean() {
    println "Launching cleanup..."
    export_vars
    teardown
    println "Not deleting ${BULLET_DOWNLOADS}, ${HOME}/.nvm or nvm additions to ${HOME}/{.profile, .bash_profile, .zshrc, .bashrc}..."
    println "Cleaned up ${BULLET_HOME} and /tmp"
    println "To delete all download artifacts (excluding nvm), do:"
    println "    rm -rf ${BULLET_HOME}"
    unset_all
}

if [ $# -eq 0 ]; then
    launch
else
    clean
fi
