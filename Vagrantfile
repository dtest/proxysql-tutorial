# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.9.1"
VAGRANTFILE_API_VERSION = "2"

### Scenario based variables (Use vagrant_config.yml in scenario folder) ###
# Customize to avoid network clashes of VMs
IP_BLOCK = "192.168.41."
###########

### Local Environment Variables (use ENVIRONMENT variables) ###
# Configure for environment
RAM_ASSIGNED = if ENV['VAGRANT_VM_MEMORY_SIZE']!=nil then ENV['VAGRANT_VM_MEMORY_SIZE'].to_i else 1024 end
###########

# Ability to override the default vagrant file from a scenario's setup.sh script setting this environment variable.
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.boot_timeout = 600

  # scenario['servers'].each_with_index do |server, machine_id|
  config.vm.define "tutorial" do |node|
    node.vm.box = "ubuntu/trusty64"
    node.vm.network "private_network", ip: "#{IP_BLOCK}#{100}"
    node.vm.hostname = "tutorial"
    node.vm.provider :virtualbox do |vb|
      vb.name = "proxysql_tutorial"
      vb.memory = RAM_ASSIGNED
      vb.cpus = 1
    end
  end
end
