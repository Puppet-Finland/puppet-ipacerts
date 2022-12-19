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
  
  def remove_nickname(nickname, dirs, suffix)
    Puppet.debug("in remove_nickname")
    dirs.each do |dir| 
      # remove from nss databases
      if match_nickname_in_nss(nickname, dir)
        cmd = "/usr/bin/certutil -d #{dir} -D -n #{nickname}"
        stdout, stderr, status = Open3.capture3(cmd)
      end
      # remove from the DIT
      cmd="ldapdelete -Y GSSAPI -Q cn=#{nickname},cn=certificates,cn=ipa,cn=etc,#{suffix}"
      if match_nickname_in_ldap(nickname, suffix)
        stdout, stderr, status = Open3.capture3(cmd)
      end
    end
  end
    
  def exists?
    Puppet.debug("in exists?")
    nickname = get_nickname(resource[:filepath])
    suffix='dc=vlab,dc=openvpn,dc=in'
    Puppet.debug('Got: ' % match_nickname_in_ldap(nickname, suffix))
    file_exists?(resource[:filepath]) and match_nickname_in_ldap(nickname, suffix)
  end

  def create
    Puppet.debug('in create')
    nickname = get_nickname(resource[:filepath])
    ipa_cacert_manage('install', '-n', nickname, '-t', resource[:trustargs], resource[:filepath])
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
    Puppet.debug(nickname)
    suffix='dc=vlab,dc=openvpn,dc=in'
    match_nickname_in_ldap(nickname, suffix) and remove_nickname(nickname, dirs, suffix)
  end
end
