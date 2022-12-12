# frozen_string_literal: true
Puppet::Type.type(:ipa_ca).provide(:ruby) do

  require 'fileutils'

  confine :osfamily => :redhat
  
  commands :rpm => '/usr/bin/rpm',
           :certutil => '/usr/bin/certutil',
           :ipa_cacert_manage => '/sbin/ipa-cacert-manage',
           :ipa_certupdate => '/sbin/ipa-certupdate',
           :ldapdelete => '/bin/ldapdelete'
  
  def get_nickname(file)
    Puppet.debug("in get_nickname")
    nickname = String.new()
    nickname = file.split('/')[-1].split('.')[0].to_s
  end

  def match_nickname(nickname)
    Puppet.debug("in match_nickname")
    found = false
    cmd='/sbin/ipa-cacert-manage -q list'
    stdout, stderr, status = Open3.capture3(cmd)
    Puppet.debug(stdout.include?(nickname) ? found = true : found = false)
    stdout.include?(nickname) ? found = true : found = false
  end

  def match_nickname_in_nss(nickname, dir)
    Puppet.debug("in match_nickname_in_nss")
    found = false
    cmd="/usr/bin/certutil -d #{dir} -L"
    stdout, stderr, status = Open3.capture3(cmd)
    stdout.include?(nickname) ? found = true : found = false
  end

  def match_nickname_in_ldap(nickname, suffix)
    Puppet.debug("in match_nickname_in_ldap")
    found = false
    cmd="/bin/ldapsearch -Y GSSAPI -QLLL -b #{suffix} \"\(cn=#{nickname}\)\" dn"
    stdout, stderr, status = Open3.capture3(cmd)
    stdout.strip.include?(nickname) ? found = true : found = false
  end
  
  def file_exists?(file)
    Puppet.debug("in file_exists?")
    File.file?(file)
  end
  
  def ipa_update()
    Puppet.debug('in update_ipa')
    Open3.popen3(ipa_certupdate('-v')) do | stdin, stdout, stderr, wait_thr |
      pid = wait_thr.pid
      exit_status = wait_thr.value
    end
  end

  def remove_nickname(nickname, dirs, suffix)
    Puppet.debug("in remove_nickname")
    dirs.each do |dir| 
      # remove from nss databases
      if match_nickname_in_nss(nickname, dir)
        cmd = "/usr/bin/certutil -d #{dir} -D -n #{nickname}"
        Open3.popen3(cmd) do | stdin, stdout, stderr, wait_thr |
          pid = wait_thr.pid
          exit_status = wait_thr.value
        end
      end
      # remove from the DIT
      cmd="ldapdelete -Y GSSAPI -Q cn=#{nickname},cn=certificates,cn=ipa,cn=etc,#{suffix}"
      if match_nickname_in_ldap(nickname, suffix)
        Open3.popen3(cmd) do | stdin, stdout, stderr, wait_thr |
          pid = wait_thr.pid
          exit_status = wait_thr.value
        end
        ipa_update()
      end
    end
  end
  
  def exists?
    Puppet.debug("in exists?")
    nickname = get_nickname(resource[:filepath])
    file_exists?(resource[:filepath]) and match_nickname(nickname)
  end

  def create
    Puppet.debug('in create')
    nickname = get_nickname(resource[:filepath])
    ipa_cacert_manage('install', '-n', nickname, '-t', resource[:trustargs], resource[:filepath])
    ipa_update
  end

  def destroy
    Puppet.debug('in destroy')
    dirs = Array[
      '/etc/ipa/nssdb',
      '/etc/pki/pki-tomcat/alias',
      '/etc/dirsrv/slapd-VLAB-OPENVPN-IN',
      '/etc/httpd/alias'
    ]
    nickname = get_nickname(resource[:filepath])
    suffix='dc=vlab,dc=openvpn,dc=in'
    remove_nickname(nickname, dirs, suffix)
  end
end
