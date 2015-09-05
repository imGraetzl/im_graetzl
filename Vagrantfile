# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Use Ubuntu 14.04 Trusty Tahr 64-bit as our operating system
  config.vm.box = "ubuntu/trusty64"
  config.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: ".ruby-version"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Configurate the virtual machine to use 2GB of RAM
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
  end

  # Forward the Rails server default port to the host
  config.vm.network :forwarded_port, guest: 3000, host: 3000

  # Use Chef Solo to provision our virtual machine
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ["cookbooks", "site-cookbooks"]

    chef.add_recipe "apt"
    chef.add_recipe "build-essential"
    #chef.add_recipe "sudo"

    chef.add_recipe "git"
    chef.add_recipe "nodejs"
    chef.add_recipe "phantomjs"

    # ruby
    chef.add_recipe "ruby_build"
    chef.add_recipe "rbenv::user"
    chef.add_recipe "rbenv::vagrant"

    # RVM
    # chef.add_recipe "rvm::vagrant"
    # chef.add_recipe "rvm::system"

    chef.add_recipe "imagemagick"
    chef.add_recipe "imagemagick::devel"
    #chef.add_recipe "rvm::system"

    # db
    chef.add_recipe "postgresql::server"
    chef.add_recipe "postgresql::client"
    #chef.add_recipe "postgresql::postgis"
    #chef.add_recipe "postgresql::setup_users"
    #chef.add_recipe "postgis"
    chef.add_recipe "postgresql::server_dev"
    chef.add_recipe "postgresql::postgis"
    chef.add_recipe "postgresql::setup_users"
    #chef.add_recipe "database"


    chef.json = {
      rbenv: {
        user_installs: [{
          user: 'vagrant',
          rubies: ["2.2.1"],
          global: "2.2.1"
        }]
      },
      postgresql: {
        version: "9.4",
        password: {
          postgres: 'password'
        },
        users: [
          {
            username: "vagrant",
            password: "password",
            superuser: true,
            replication: false,
            createdb: true,
            createrole: true,
            inherit: true,
            replication: false,
            login: true
          }
        ]
      }
    }
  end

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   sudo apt-get update
  #   sudo apt-get install -y apache2
  # SHELL

  # Scripts to run on vagrant up:
  # Install bundler and gems
  config.vm.provision :shell, privileged: false, inline: %q{cd /vagrant && /home/vagrant/.rbenv/shims/gem install bundler}
  config.vm.provision :shell, privileged: false, inline: %q{cd /vagrant && /home/vagrant/.rbenv/bin/rbenv rehash}
  config.vm.provision :shell, privileged: false, inline: %q{cd /vagrant && /home/vagrant/.rbenv/shims/bundle}
  config.vm.provision :shell, privileged: false, inline: %q{cd /vagrant && /home/vagrant/.rbenv/bin/rbenv rehash}

  # Setup and populate db
  config.vm.provision :shell, privileged: false, inline: %q{cd /vagrant && /home/vagrant/.rbenv/shims/rake db:setup}
  config.vm.provision :shell, privileged: false, inline: %q{cd /vagrant && /home/vagrant/.rbenv/shims/rake db:populate}
  #config.vm.provision :shell, run: 'always', privileged: false, inline: %q{cd /vagrant && /home/vagrant/.rbenv/shims/rails s -b 0.0.0.0}

  # always run migrations:
  config.vm.provision :shell, run: 'always', privileged: false, inline: %q{cd /vagrant && rake db:migrate}
end
