# -*- mode: ruby -*-
# vi: set ft=ruby :

# Verify whether required plugins are installed.
required_plugins = [ "vagrant-disksize" ]
required_plugins.each do |plugin|
  if not Vagrant.has_plugin?(plugin)
    raise "The vagrant plugin #{plugin} is required. Please run `vagrant plugin install #{plugin}`"
  end
end


Vagrant.configure("2") do |config|

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "ubuntu/bionic64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  config.vm.box_check_update = false

  # Create a forwarded port mapping   
  #config.vm.network "forwarded_port", guest: 80,   host: 8080


  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: ENV["DOCKER_IP"]

  # Share an additional folder to the guest VM.
  config.vm.synced_folder ENV["DEV_HOME_WIN"], ENV["DEV_HOME_LINUX"], mount_options: ["dmode=775", "fmode=664"]
  config.vm.synced_folder ENV["USER_HOME_WIN"], ENV["USER_HOME_LINUX"], mount_options: ["dmode=775", "fmode=664"]
  config.vm.synced_folder ENV["DOCKER_CERT_PATH_WIN"], ENV["DOCKER_CERT_PATH_LINUX"]

  config.disksize.size = ENV['VAGRANT_DISK_SIZE']

  # Provider-specific configuration
  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.memory = ENV['VAGRANT_MEMORY']
    vb.cpus = ENV['VAGRANT_VCPU']
  end

  # Provsionning  
  config.vm.provision :shell, :inline => "sudo rm /etc/localtime && sudo ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime", run: "once"
  config.vm.provision "boostrap", type: "shell", run:"once", path: "./provision/00-update-system.sh"
  config.vm.provision "docker",   type: "shell", run:"once", path: "./provision/01-install-docker.sh"
  config.vm.provision "cert",     type: "shell", run:"once", path: "./provision/02-create-certificats.sh", env: {"DOCKER_CERT_PATH_LINUX": ENV["DOCKER_CERT_PATH_LINUX"]}
  config.vm.provision "tls",      type: "shell", run:"once", path: "./provision/03-active-tls.sh"

  # Plugin configuration
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
  end

end
