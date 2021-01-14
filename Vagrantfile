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
    str.concat(' autoelb.kub') if haproxy?
    str.concat("' >> /etc/hosts \n")
  end

  def haproxy?
    @type.eql?('haproxy')
  end

  def kub?
    @type.eql?('kub')
  end

  def deploy?
    @type.eql?('deploy')
  end
end

class Settings

  attr_reader :etc_hosts, :common_settings, :wordpress_url

  def initialize(etc_hosts, option)

    @etc_hosts = etc_hosts

    ask_nginx_ingress && ask_wordpress && ask_wordpress_url if %w[provision up].include?(option)
  end

  def wordpress?
    @wordpress == 'y'
  end

  private

  def ask_nginx_ingress
    print "Do you want nginx ingress controller (y/N) ? \n"
    @ingress_nginx = $stdin.gets.chomp
    @ingress_nginx == 'y'
  end

  def ask_wordpress
    print "Do you want a wordpress instance in your kubernetes cluster (y/N) ? \n"
    @wordpress = $stdin.gets.chomp
    @wordpress == 'y'
  end

  def ask_wordpress_url
    print "Which url for your wordpress ? \n"
    url = $stdin.gets.chomp
    @wordpress_url = url.empty? ? 'wordpress.kub' : url
  end
end

# set servers list and their parameters
NODES = [
  Node.new('haprox', '192.168.12.10', 1, 512, 'haproxy'),
  Node.new('kmaster', '192.168.12.11', 4, 4096, 'kub'),
  Node.new('knode1', '192.168.12.12', 2, 2048, 'kub'),
  Node.new('deploy', '192.168.12.20', 1, 512, 'deploy')
].freeze

Vagrant.configure(2) do |config|

  settings = Settings.new(NODES.map(&:etc_hosts).join, ARGV[0])

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
        v.customize ['modifyvm', :id, '--groups', '/k8s']
      end

      cfg.vm.provision :shell, inline: settings.etc_hosts
      cfg.vm.provision :shell, path: 'install_haproxy.sh' if node.haproxy?
      cfg.vm.provision :shell, path: 'common_settings.sh' if node.kub? || node.deploy?
      if node.deploy?
        cfg.vm.provision :shell, path: 'install_kubespray.sh'
        if settings.wordpress?
          cfg.vm.provision :shell, path: 'install_nfs.sh'
          cfg.vm.provision :shell, path: 'install_wordpress.sh', args: settings.wordpress_url
        end
      end
    end
  end
end
