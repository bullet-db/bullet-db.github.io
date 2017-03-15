#! /usr/bin/env bash

set -euo pipefail


BULLET_EXAMPLES_VERSION=0.1.2
BULLET_UI_VERSION=0.1.0
BULLET_WS_VERSION=0.0.1
JETTY_VERSION=9.3.16.v20170120
STORM_VERSION=1.0.3
NVM_VERSION=0.33.1
NODE_VERSION=6.9.4

println() {
    local DATE="$(date)"
    local FORMAT=$1
    shift
    printf "\n${DATE} [BULLET-QUICKSTART]: "
    printf "${FORMAT}\n" $*
}

print_versions() {
    println "Using the following artifacts..."
    println "Bullet Examples:    ${BULLET_EXAMPLES_VERSION}"
    println "Bullet Web Service: ${BULLET_WS_VERSION}"
    println "Bullet UI:          ${BULLET_UI_VERSION}"
    println "Jetty:              ${JETTY_VERSION}"
    println "Storm:              ${STORM_VERSION}"
    println "NVM:                ${NVM_VERSION}"
    println "Node.js:            ${NODE_VERSION}"
    println "Done!"
}

export_vars() {
    local PWD="$(pwd)"

    println "Exporting some variables..."
    export BULLET_HOME="${PWD}/bullet-quickstart"
    export BULLET_EXAMPLES=$BULLET_HOME/bullet-examples
    println "Done!"
}

setup() {
    println "Setting up directories..."
    mkdir -p $BULLET_HOME/backend/storm
    mkdir -p $BULLET_HOME/service
    mkdir -p $BULLET_HOME/ui
    println "Done!"
}

install_bullet_examples() {
    cd "${BULLET_HOME}"
    println "Downloading Bullet Examples ${BULLET_EXAMPLES_VERSION}..."
    curl -#LO "https://github.com/yahoo/bullet-docs/releases/download/v${BULLET_EXAMPLES_VERSION}/examples_artifacts.tar.gz"
    println "Installing Bullet Examples..."
    tar -xzf examples_artifacts.tar.gz
    println "Done!"
}

install_storm() {
    local STORM="apache-storm-${STORM_VERSION}"

    cd "${BULLET_HOME}/backend"

    println "Downloading Storm ${STORM_VERSION}..."
    curl -#O "http://apache.org/dist/storm/${STORM}/${STORM}.zip"

    println "Installing Storm ..."
    unzip -qq "${STORM}.zip"

    println "Configuring Storm ..."
    export PATH="$BULLET_HOME/backend/${STORM}/bin/:${PATH}"
    echo 'drpc.servers: ["127.0.0.1"]' >> "${STORM}/conf/storm.yaml"
    println "Done!"
}

launch_storm() {
    println "Launching Storm Dev Zookeeper..."
    storm dev-zookeeper &

    println "Launching Storm Nimbus..."
    storm nimbus &

    println "Launching Storm DRPC..."
    storm drpc &

    println "Launching Storm UI..."
    storm ui &

    println "Launching Storm LogViewer..."
    storm logviewer &

    println "Launching a Storm Supervisor..."
    storm supervisor &

    println "Sleeping for 60 s to ensure all components are up..."
    println "====================================================================================================="
    sleep 60
    println "====================================================================================================="
    println "Done!"
}

launch_bullet_storm() {
    println "Copying Bullet topology configuration and artifacts..."
    cp "${BULLET_EXAMPLES}/storm"/* "${BULLET_HOME}/backend/storm"

    println "Launching the Bullet topology..."
    cd "${BULLET_HOME}/backend/storm" && ./launch.sh

    println "Sleeping for 30 s to ensure all Bullet Storm components are up..."
    sleep 30

    println "Getting one random record from the Bullet topology..."
    curl -s -X POST -d '{}' http://localhost:3774/drpc/bullet
    println "Done!"
}

install_jetty() {
    cd "${BULLET_HOME}/service"

    println "Downloading Jetty ${JETTY_VERSION}..."
    curl -#O "http://central.maven.org/maven2/org/eclipse/jetty/jetty-distribution/${JETTY_VERSION}/jetty-distribution-${JETTY_VERSION}.zip"

    println "Installing Jetty..."
    unzip -qq "jetty-distribution-${JETTY_VERSION}.zip"
    println "Done!"
}

launch_bullet_web_service() {
    cd "${BULLET_HOME}/service/jetty-distribution-${JETTY_VERSION}"

    println "Downloading Bullet Web Service ${BULLET_WS_VERSION}..."
    curl -#Lo webapps/bullet-service.war \
             "http://jcenter.bintray.com/com/yahoo/bullet/bullet-service/${BULLET_WS_VERSION}/bullet-service-${BULLET_WS_VERSION}.war"

    println "Configuring Bullet Web Service..."
    cp "${BULLET_EXAMPLES}/web-service"/example_* "${BULLET_HOME}/service/jetty-distribution-${JETTY_VERSION}"

    println "Launching Bullet Web Service..."
    cd "${BULLET_HOME}/service/jetty-distribution-${JETTY_VERSION}"
    java -jar -Dbullet.service.configuration.file="example_context.properties" -Djetty.http.port=9999 start.jar > logs/out 2>&1 &

    println "Sleeping for 30 s to ensure Bullet Web Service is up..."
    sleep 30

    println "Getting one random record from Bullet through the Web Service..."
    curl -s -X POST -d '{}' http://localhost:9999/bullet-service/api/drpc
    println "Getting column schema from the Web Service..."
    curl -s http://localhost:9999/bullet-service/api/columns
    println "Finished Bullet Web Service test"
}

install_node() {
    println "Downloading and installing NVM ${NVM_VERSION}..."
    curl -s "https://raw.githubusercontent.com/creationix/nvm/v${NVM_VERSION}/install.sh" | bash

    source ~/.bashrc
    println "Installing Node ${NODE_VERSION}..."

    # NVM unset var bug
    set +u
    nvm install "v${NODE_VERSION}"
    nvm use "v${NODE_VERSION}"
    set -u

    println "Done!"
}

launch_bullet_ui() {
    cd "${BULLET_HOME}/ui"

    println "Downloading Bullet UI ${BULLET_UI_VERSION}..."
    curl -#LO "https://github.com/yahoo/bullet-ui/releases/download/v${BULLET_UI_VERSION}/bullet-ui-v${BULLET_UI_VERSION}.tar.gz"

    println "Installing Bullet UI..."
    tar -xzf "bullet-ui-v${BULLET_UI_VERSION}.tar.gz"

    println "Configuring Bullet UI..."
    cp "${BULLET_EXAMPLES}/ui/env-settings.json" config/

    println "Launching Bullet UI..."
    PORT=8800 node express-server.js &

    println "Sleeping for 5 s to ensure Bullet UI is up..."
    sleep 5
    println "Done!"
}

cleanup() {
    set +eo pipefail

    ps aux | grep "[e]xpress-server.js" | awk '{print $2}' | xargs kill

    ps aux | grep "[e]xample_context.properties" | awk '{print $2}' | xargs kill

    ps aux | grep "[a]pache-storm-${STORM_VERSION}" | awk '{print $2}' | xargs kill

    rm -rf "${BULLET_HOME}" /tmp/dev-storm-zookeeper /tmp/jetty-*

    set -eo pipefail
}

teardown() {
    println "Killing all Bullet components..."
    cleanup &> /dev/null
    println "Done!"
}

unset_all() {
    unset -f print_versions println export_vars setup install_bullet_examples \
             install_storm launch_storm launch_bullet_storm \
             install_jetty launch_bullet_web_service \
             install_node launch_bullet_ui \
             cleanup teardown unset_all launch
}

launch() {
    print_versions
    export_vars

    teardown

    setup
    install_bullet_examples

    install_storm
    launch_storm
    launch_bullet_storm

    install_jetty
    launch_bullet_web_service

    install_node
    launch_bullet_ui

    println "All components launched! Visit localhost:8800 (default) for the UI"
    unset_all
}

clean() {
    export_vars
    teardown
    unset_all
}

if [ $# -eq 0]; then
    launch
else
    clean
fi
