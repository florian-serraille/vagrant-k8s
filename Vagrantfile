class Node

  attr_reader :hostname, :ip, :cpu, :memory, :type

  def initialize(hostname, ip, cpu, memory, type)
    @hostname = hostname
    @ip = ip
    @cpu = cpu
    @memory = memory
    @type = type
  end

  def etc_hosts
    str = "echo '#{ip}    #{hostname}"
    str.concat(' autoelb.kub') if type.eql?('haproxy')
    str.concat("' >> /etc/hosts \n")
  end
end

# set servers list and their parameters
NODES = [
  Node.new('autohaprox', '192.168.12.10', 1, 512, 'haproxy'),
  Node.new('autokmaster', '192.168.12.11', 4, 4096, 'kub'),
  Node.new('autoknode1', '192.168.12.12', 2, 2048, 'kub'),
  Node.new('autodep', '192.168.12.20', 1, 512, 'deploy')
].freeze

etc_hosts = NODES.map(&:etc_hosts).join

Vagrant.configure(2) do |config|

  config.vm.box = 'ubuntu/bionic64'
  config.vm.box_url = 'ubuntu/bionic64'

  NODES.each do |node|
    config.vm.define node.hostname do |cfg|
      cfg.vm.hostname = node.hostname
      cfg.vm.network 'private_network', ip: node.ip
      cfg.vm.provider 'virtualbox' do |v|
        v.customize ['modifyvm', :id, '--cpus', node.cpu]
        v.customize ['modifyvm', :id, '--memory', node.memory]
        v.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
        v.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
        v.customize ['modifyvm', :id, '--name', node.hostname]
      end
      cfg.vm.provision :shell, :inline => etc_hosts
    end
  end

end
