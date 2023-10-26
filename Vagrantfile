# -*- mode: ruby -*-
# vi: set ft=ruby :
## 1. Definindo as características das máquinas virtuais 
k8s = {
  'controlplane' => {'memory' => '2048', 'cpus' => 2, 'ip' => '10', 'box' => 'generic/debian11'},
  'worker01' => {'memory' => '2048', 'cpus' => 1, 'ip' => '20', 'box' => 'generic/debian11'},
#  'worker02' => {'memory' => '1024', 'cpus' => 1, 'ip' => '30', 'box' => 'generic/debian11'},
#  'worker03' => {'memory' => '1024', 'cpus' => 1, 'ip' => '40', 'box' => 'generic/debian11'},
}
nfs = {
  'nfs' => {'memory' => '1024', 'cpus' => 1, 'ip' => '200', 'box' => 'generic/debian11'},
}
## 1. Aplicando as configurações no virtualizador
Vagrant.configure('2') do |config|
  config.vm.box_check_update = false					## opcional: adiar a checagem de updates
  k8s.each do |name, conf|						## para cada item do dicionário de vms, faça:
    config.vm.define "#{name}" do |my|
      my.vm.provision 'shell', path: 'provision-k8s.sh'
      my.vm.box = conf['box']						## seleciona a box com a distribuição linux a ser utilizada
      my.vm.hostname = "#{name}.example.com"				## define o hostname da máquina
      my.vm.network 'private_network', ip: "192.168.56.#{conf['ip']}"	## define o ip de cada máquina de acordo com o range do Virtualbox
      my.vm.provider 'libvirt' do |vb|
        vb.memory = conf['memory']					## define quantidade de recurso de memória
        vb.cpus = conf['cpus']						## define quantidade de vCPUs 
      end
    end
  end
  nfs.each do |name, conf|
    config.vm.define "#{name}" do |my|
      my.vm.provision 'shell', path: 'provision-nfs.sh'
      my.vm.box = conf['box']                                           ## seleciona a box com a distribuição linux a ser utilizada
      my.vm.hostname = "#{name}.example.com"                            ## define o hostname da máquina
      my.vm.network 'private_network', ip: "192.168.56.#{conf['ip']}"   ## define o ip de cada máquina de acordo com o range do Virtualbox
      my.vm.provider 'libvirt' do |vb|
        vb.memory = conf['memory']                                      ## define quantidade de recurso de memória
        vb.cpus = conf['cpus']                                          ## define quantidade de vCPUs
      end
    end
  end
end
