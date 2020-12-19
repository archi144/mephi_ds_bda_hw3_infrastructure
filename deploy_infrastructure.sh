#!/bin/bash

config_repo_name="mephi_ds_bda_hw3_infrastructure"      # name of the github repository with configs and scrips
app_repo_name="mephi_ds_bda_hw3_app"                 # name of the to the github repository with app code

logstash_setup() {
    logstash_version=$1
    ls_config_name=$(ls $config_repo_name/configs/logstash/)
    echo "Downloading Logstash $logstash_version"
    wget https://artifacts.elastic.co/downloads/logstash/logstash-${logstash_version}-linux-x86_64.tar.gz
    tar -xf logstash-*tar.gz
    echo "Setup LS_HOME env"
    echo "export LS_HOME=$(pwd)/logstash-$logstash_version" >> ~/.bashrc
    . ~/.bashrc
    echo "LS_HOME=$LS_HOME is set up "
    echo "Starting Logstash in the background"
    nohup $LS_HOME/bin/logstash -f $config_repo_name/configs/logstash/$ls_config_name > logstash.log &
    echo "Logstash started and listen on 11111 port"
}

elastic_setup() {
    elastic_version=$1
    echo "Downloading Elasticsearch $elastic_version"
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${elastic_version}-linux-x86_64.tar.gz
    tar -xf elasticsearch-*tar.gz
    echo "Setup ES_HOME env"
    echo "export ES_HOME=$(pwd)/elasticsearch-$elastic_version" >> ~/.bashrc
    . ~/.bashrc
    echo "ES_HOME=$ES_HOME is set up"
    echo "Starting Elasticsearch in the background"
    nohup $ES_HOME/bin/elasticsearch > elasticsearch.log &
    echo "Elasticsearch started on 9200 port"
}

grafana_setup() {
    grafana_version=$1
    echo "Downloading Grafana $grafana_version"
    wget https://dl.grafana.com/oss/release/grafana-${grafana_version}.linux-amd64.tar.gz
    tar -xf grafana-*.tar.gz
    echo "Setup GRAFANA_HOME env"
    echo "export GRAFANA_HOME=$(pwd)/grafana-$grafana_version" >> ~/.bashrc
    . ~/.bashrc
    echo "GRAFANA_HOME=$GRAFANA_HOME is set up"
    echo "Provision datasources"
    cp $config_repo_name/configs/grafana/provisioning/datasources/datasource.yaml $GRAFANA_HOME/conf/provisioning/datasources/
    echo "Provision dashboards"
    cp -r $config_repo_name/configs/grafana/provisioning/dashboards/* $GRAFANA_HOME/conf/provisioning/dashboards/
    nohup $GRAFANA_HOME/bin/grafana-server -homepath $GRAFANA_HOME web > grafana.log &
    echo "Grafana started on 3000 port"
}

app_setup() {
    pull_app
    sudo apt install -y python3
    sudo apt install -y python3-pip
    cd $app_repo_name
    pip3 install -r requirements.txt
    nohup python3 main.py pizza > app.log &
}

main () {
    cd ~
    sudo apt update -y
    elastic_setup 7.10.1
    logstash_setup 7.10.1
    app_setup
    grafana_setup 7.3.5
}

main