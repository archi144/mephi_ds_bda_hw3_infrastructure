#!/bin/bash

config_repo_name="mephi_ds_bda_hw3_infrastructure"      # name of the github repository with configs and scrips
app_repo_name="mephi_ds_bda_hw3_app"                 # name of the to the github repository with app code

virtualbox_setup() {
    sudo yum install –y patch gcc kernel-headers kernel-devel make perl wget
    sudo wget http://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo -P /etc/yum.repos.d
    sudo yum install -y VirtualBox-6.0
}

vagrant_setup() {
    vagrant_version=$1
    echo "Installing Vagrant $vagrant_version..."
    sudo yum install -y https://releases.hashicorp.com/vagrant/${vagrant_version}/vagrant_${vagrant_version}_x86_64.rpm && vagrant --version
    echo "Making vagrant dir"
    mkdir -p ~/vagrant-ubuntu && cd ~/vagrant-ubuntu
    echo "Pulling configs and scripts from github"
    pull_configs
    echo "Pull configs and scripts succeed"
    cp $config_repo_name/configs/vagrant/Vagranfile .
    sudo sysctl -w vm.max_map_count=262144                # it's need to just for avoid the posiible future problems
    echo "Pulling app"
    pull_app
    echo "Pull app succeed"
    echo "Substitute secret files..."
    cp -u ~/CREDENTIALS.txt $app_repo_name/
    echo "Substitution succeed"
    echo "Starting Vagrant VM"
    vagrant up
    echo "Uploading configs and scripts to the guest"
    vagrant upload $config_repo_name
    echo "Upload succeed"
    echo "Uploading app sources to the guest"
    vagrant upload $app_repo_name
    echo "Upload succeed"
}

pull_configs() {
    git clone https://github.com/archi144/$config_repo_name.git
}

pull_app() {
    git clone https://github.com/archi144/$app_repo_name.git
}

main() {
    sudo yum update -y
    virtualbox_setup
    vagrant_setup 2.2.6
}

main