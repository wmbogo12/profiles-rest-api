# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.

  # Specify the base box
  config.vm.box = "ubuntu/xenial64"

  # Forward port 8080
  config.vm.network "forwarded_port", host_ip: "127.0.0.1", guest: 8080, host: 8080

  # Provision the VM
  config.vm.provision "shell", inline: <<-SHELL
    # Update and upgrade the server packages
    sudo apt-get update
    sudo apt-get -y upgrade

    # Set Ubuntu Language
    sudo locale-gen en_GB.UTF-8

    # Install Python3, SQLite, and pip3
    sudo apt-get install -y python3-dev sqlite python3-pip

    # Install pip 20.3.4 (the last version compatible with Python 3.5)
    sudo python3 -m pip install pip==20.3.4

    # Install pbr (missing dependency for virtualenvwrapper)
    sudo python3 -m pip install pbr

    # Install virtualenvwrapper (this will install the latest compatible version)
    sudo python3 -m pip install virtualenvwrapper

    # Add virtualenvwrapper configuration to bashrc if not already added
    if ! grep -q VIRTUALENV_ALREADY_ADDED /home/vagrant/.bashrc; then
      cat <<EOF >> /home/vagrant/.bashrc
# VIRTUALENV_ALREADY_ADDED
export WORKON_HOME=~/.virtualenvs
export PROJECT_HOME=/vagrant
source $(which virtualenvwrapper.sh)
EOF
    fi
  SHELL
end
