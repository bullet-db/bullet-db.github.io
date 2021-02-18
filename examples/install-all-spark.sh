#! /usr/bin/env bash

set -euo pipefail

BULLET_EXAMPLES_VERSION=1.0.0
BULLET_UI_VERSION=1.0.0
BULLET_WS_VERSION=1.0.0
BULLET_KAFKA_VERSION=1.0.1
BULLET_SPARK_VERSION=1.0.0
KAFKA_VERSION=2.3.1
SPARK_VERSION=3.0.1
NVM_VERSION=0.37.2
NODE_VERSION=10.20.1

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
    println "Bullet Spark:       ${BULLET_SPARK_VERSION}"
    println "Bullet Web Service: ${BULLET_WS_VERSION}"
    println "Bullet UI:          ${BULLET_UI_VERSION}"
    println "Bullet Kafka:       ${BULLET_KAFKA_VERSION}"
    println "Spark:              ${SPARK_VERSION}"
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
    export BULLET_EXAMPLES="$BULLET_HOME/bullet-examples"
    export BULLET_DOWNLOADS="$BULLET_HOME/bullet-downloads"
    export BULLET_SPARK="${BULLET_HOME}/backend/spark"
    export KAFKA_DISTRO="kafka_2.12-${KAFKA_VERSION}"
    export KAFKA_DIR="${BULLET_HOME}/pubsub"
    export SPARK_DISTRO="spark-${SPARK_VERSION}-bin-hadoop2.7"
    export SPARK_DIR="${BULLET_SPARK}/${SPARK_DISTRO}"
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
    println "Downloading Kafka ${KAFKA_VERSION}..."
    download "https://archive.apache.org/dist/kafka/${KAFKA_VERSION}" "${KAFKA_DISTRO}.tgz"

    println "Installing Kafka to ${KAFKA_DIR}..."
    tar -xzf ${BULLET_DOWNLOADS}/${KAFKA_DISTRO}.tgz -C ${KAFKA_DIR}

    println "Done!"
}

install_bullet_kafka() {
    local BULLET_KAFKA="bullet-kafka-${BULLET_KAFKA_VERSION}-fat.jar"

    println "Downloading bullet-kafka ${BULLET_KAFKA_VERSION}..."
    download "http://jcenter.bintray.com/com/yahoo/bullet/bullet-kafka/${BULLET_KAFKA_VERSION}" "${BULLET_KAFKA}"
    cp ${BULLET_DOWNLOADS}/${BULLET_KAFKA} ${BULLET_HOME}/pubsub/${BULLET_KAFKA}

    println "Done!"
}

launch_kafka() {
    local KAFKA_INSTALL_DIR=${KAFKA_DIR}/${KAFKA_DISTRO}
    println "Launching Zookeeper..."
    $KAFKA_INSTALL_DIR/bin/zookeeper-server-start.sh $KAFKA_INSTALL_DIR/config/zookeeper.properties &> ${KAFKA_INSTALL_DIR}/zk.log &
    println "Sleeping for 10s to ensure Zookeeper is up..."
    sleep 10

    println "Launching Kafka..."
    $KAFKA_INSTALL_DIR/bin/kafka-server-start.sh $KAFKA_INSTALL_DIR/config/server.properties &> ${KAFKA_INSTALL_DIR}/kafka.log &
    println "Sleeping for 10s to ensure Kafka is up..."
    sleep 10
    println "Done!"
}

create_topics() {
    local KAFKA_DIR=${KAFKA_DIR}/${KAFKA_DISTRO}
    set +e
    println "Creating Kafka topics ${KAFKA_TOPIC_REQUESTS} and ${KAFKA_TOPIC_RESPONSES}..."
    $KAFKA_DIR/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic ${KAFKA_TOPIC_REQUESTS}
    $KAFKA_DIR/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic ${KAFKA_TOPIC_RESPONSES}
    set -e

    println "Sleeping for 10s to ensure Kafka topics are created..."
    println "Done!"
}

launch_bullet_web_service() {
    local BULLET_WS_JAR="bullet-service-${BULLET_WS_VERSION}-embedded.jar"
    local BULLET_SERVICE_HOME="${BULLET_HOME}/service"

    println "Downloading Bullet Web Service ${BULLET_WS_VERSION}..."
    download "http://jcenter.bintray.com/com/yahoo/bullet/bullet-service/${BULLET_WS_VERSION}" "${BULLET_WS_JAR}"

    println "Configuring Bullet Web Service and plugging in Kafka PubSub..."
    cp "${BULLET_DOWNLOADS}/${BULLET_WS_JAR}" "${BULLET_SERVICE_HOME}/bullet-service.jar"
    cp "${BULLET_EXAMPLES}/web-service/"example_* "${BULLET_SERVICE_HOME}/"

    println "Launching Bullet Web Service with the Kafka PubSub..."
    cd "${BULLET_SERVICE_HOME}"
    java -Dloader.path=${BULLET_HOME}/pubsub/bullet-kafka-${BULLET_KAFKA_VERSION}-fat.jar -jar ${BULLET_SERVICE_HOME}/bullet-service.jar \
         --bullet.pubsub.config=${BULLET_SERVICE_HOME}/example_kafka_pubsub_config.yaml \
         --bullet.query.config=${BULLET_SERVICE_HOME}/example_query_config.yaml \
         --bullet.schema.file=${BULLET_SERVICE_HOME}/example_columns.json \
         --server.port=9999  --logging.path="${BULLET_SERVICE_HOME}" \
         --logging.file=log.txt &> "${BULLET_SERVICE_HOME}/log.txt" &

    println "Sleeping for 15 s to ensure Bullet Web Service is up..."
    sleep 15

    println "Testing the Web Service"
    println "Getting column schema from the Web Service..."
    println ""
    curl -s http://localhost:9999/api/bullet/columns
    println ""
    println "Getting one random record from Bullet through the Web Service..."
    curl -s -H 'Content-Type: text/plain' -X POST -d 'SELECT * FROM STREAM(2000, TIME) LIMIT 1;' http://localhost:9999/api/bullet/queries/sse-query
    println ""
    println "Finished Bullet Web Service test!"
}

install_spark() {
    println "Downloading Spark version ${SPARK_VERSION}..."
    download "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}" "${SPARK_DISTRO}.tgz"

    println "Installing Spark version ${SPARK_VERSION}..."
    cp ${BULLET_DOWNLOADS}/${SPARK_DISTRO}.tgz ${BULLET_SPARK}/
    tar -xzf "${BULLET_SPARK}/${SPARK_DISTRO}.tgz" -C ${BULLET_SPARK}
    println "Done!"
}

install_bullet_spark() {
    local BULLET_SPARK_JAR="bullet-spark-${BULLET_SPARK_VERSION}-standalone.jar"

    println "Downloading Bullet Spark version ${BULLET_SPARK_VERSION}..."
    download "http://jcenter.bintray.com/com/yahoo/bullet/bullet-spark/${BULLET_SPARK_VERSION}" "${BULLET_SPARK_JAR}"

    println "Installing Bullet Spark version ${BULLET_SPARK_VERSION}..."
    cp ${BULLET_DOWNLOADS}/${BULLET_SPARK_JAR} ${BULLET_SPARK}/bullet-spark.jar
    println "Done!"
}

launch_bullet_spark() {
    local BULLET_KAFKA_JAR="${BULLET_HOME}/pubsub/bullet-kafka-${BULLET_KAFKA_VERSION}-fat.jar"
    local BULLET_SPARK_JAR="${BULLET_SPARK}/bullet-spark.jar"
    local BULLET_EXAMPLE_JAR="${BULLET_SPARK}/bullet-spark-example.jar"
    local BULLET_EXAMPLE_SETTINGS="${BULLET_SPARK}/bullet_spark_kafka_settings.yaml"

    println "Copying Bullet Spark configuration and artifacts..."
    cp $BULLET_HOME/bullet-examples/backend/spark/* $BULLET_SPARK
    cd ${BULLET_SPARK}
    println "Launching Bullet Spark..."
    println "=============================================================================="
    ${SPARK_DIR}/bin/spark-submit \
        --master local[10]  \
        --class com.yahoo.bullet.spark.BulletSparkStreamingMain \
        --driver-class-path $BULLET_SPARK_JAR:$BULLET_KAFKA_JAR:$BULLET_EXAMPLE_JAR \
        $BULLET_SPARK_JAR \
        --bullet-spark-conf=$BULLET_EXAMPLE_SETTINGS &> log.txt &

    println "Sleeping for 15 s to ensure Bullet Spark is up and running..."
    println "=============================================================================="
    sleep 15

    println "Done!"
}

install_node() {
    # NVM unset var bug
    set +eu

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

    set -eu

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
    local KAFKA_INSTALL_DIR=${KAFKA_DIR}/${KAFKA_DISTRO}
    set +e

    pkill -f "[e]xpress-server.js"
    pkill -f "[e]xample_kafka_pubsub_config.yaml"
    pkill -9 -f "[b]ullet-spark"
    ${KAFKA_INSTALL_DIR}/bin/kafka-server-stop.sh
    ${KAFKA_INSTALL_DIR}/bin/zookeeper-server-stop.sh

    sleep 5

    rm -rf "${BULLET_EXAMPLES}" "${BULLET_HOME}/backend" "${BULLET_HOME}/service" \
           "${BULLET_HOME}/ui" "${BULLET_HOME}/pubsub" \
           /tmp/zookeeper /tmp/kafka-logs/ /tmp/spark-checkpoint

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
             install_kafka install_bullet_kafka launch_kafka create_topics \
             install_spark install_bullet_spark launch_bullet_spark \
             install_web_service launch_web_service \
             install_node launch_bullet_ui \
             cleanup teardown unset_all launch clean
}

launch() {
    print_versions
    export_vars

    teardown

    setup
    install_bullet_examples

    install_kafka
    install_bullet_kafka
    launch_kafka
    create_topics

    install_spark
    install_bullet_spark
    launch_bullet_spark

    launch_bullet_web_service

    install_node
    launch_bullet_ui

    println "All components launched! Visit http://localhost:8800 (default) for the UI"
    unset_all
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
