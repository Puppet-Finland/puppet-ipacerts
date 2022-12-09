Puppet::Type.type(:ipa_ca).provide(:ruby) do
  require 'fileutils'
  require 'net/http'
  require 'uri'
  require 'open3'
  require 'openssl'

  commands :rpm => '/usr/bin/rpm',
           :certutil => '/usr/bin/certutil',
           :ipa_cacert_manage => '/sbin/ipa-cacert-manage',
           :ipa_certupdate => '/sbin/ipa-certupdate'

  confine :osfamily => :redhat
  confine :true => begin
                     rpm('-q', 'ipa-server')
                   end
  
  def exists?
    # if a CA cert is already properly installed with ipa-cacert-manage, it exists in:
    # /etc/ipa/nssdb/
    # /etc/pki/pki-tomcat/alias/
    # /etc/dirsrv/slapd-VLAB-OPENVPN-IN/
    # /etc/httpd/alias/
    # Just checking one of these is enough 
    nickname = get_nickname(resource[:file], resource[:nickname_by])
    file_exists?(resource[:file]) and match_nickname(nickname)
  end

  def create
    nickname = get_nickname(resource[:file], resource[:nickname_by])
    ipa_cacert_manage('install', '-n', nickname, '-t', resource[:trustargs], resource[:file])
   end

  def destroy
    # remove all of the nicknames in all nss databases
    # /etc/ipa/nssdb
    # /etc/pki/pki-tomcat/alias/
    # /etc/dirsrv/slapd-VLAB-OPENVPN-IN/
    dirs=Array.new('/etc/ipa/nssdb',
                   '/etc/pki/pki-tomcat/alias',
                   '/etc/dirsrv/slapd-VLAB-OPENVPN-IN',
                   '/etc/httpd/alias')
    nickname = get_nickname(resource[:file], resource[:nickname_by])
    remove_nickname(nickname, dirs)
  end

  # returns a string
  def get_nickname(file, nickname_by)

    _nickname = String.new()
    if nickname_by.to_s == 'filename'
      _nickname = file.split('/')[-1].split('.')[0].to_s
    else
      _nickname = OpenSSL::X509::Certificate.new(File.open(file)).subject.to_s
    end
    return _nickname
  end

  # returns a boolean
  def match_nickname(nickname)

    found = false
    cmd=ipa_cacert_manage('-q', 'list')
    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
      while line = stdout.gets
        if line.match(/(#{nickname})/)
          Puppet.debug("found nickname: %s" % nickname)
          found = true
          break
        end
      end
    end
    return found
  end
      
  # returns a boolean
  def file_exists?(file)
    File.file?(file)
  end
  
  def install_ca_cert(nickname, file, trustargs)

    ipa-cacert-manage('install', '-n', nickname, '-t', trustargs, file) 
    update_ipa()
  end

  def update_ipa()
    Puppet.debug('in update_ipa')
    Open3.popen3(ipa_certupdate('v')) do | stdin, stdout, stderr, wait_thr |
      pid = wait_thr.pid
      exit_status = wait_thr.value
    end
  end
end


