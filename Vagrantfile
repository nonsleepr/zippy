# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  #config.vm.box = "centos/7"
  # The box below has virtualbox additions which are required if synced_folder
  # is enabled
  config.vm.box = "bento/centos-7.2"

  config.vm.network "forwarded_port", guest: 8000, host: 8000

  # If resources folder is present on the host, "make resources" shouldn't be
  # used
  config.vm.synced_folder "../resources", "/var/local/zippy/resources"

  config.vm.provision "shell", run: "once", inline: <<-SHELL
    cd /vagrant
    sudo make dependencies
    sudo make install
    #sudo make resources
    sudo make run
  SHELL
end
