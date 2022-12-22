# frozen_string_literal: true

Puppet::Type.type(:ipa_ca).provide(:ruby) do
  require 'fileutils'

  confine osfamily: :redhat

  def get_nickname(file)
    file.split('/')[-1].split('.')[0].to_s
  end

  def match_nickname(nickname)
    cmd = '/sbin/ipa-cacert-manage -q list'
    stdout, _stderr, _status = Open3.capture3(cmd)
    stdout.include?(nickname) ? true : false
  end

  def match_nickname_in_nss(nickname, dir)
    cmd = "/usr/bin/certutil -d #{dir} -L"
    stdout, _stderr, _status = Open3.capture3(cmd)
    stdout.include?(nickname) ? true : false
  end

  def match_nickname_in_ldap(nickname, suffix)
    cmd = "/bin/ldapsearch -Y GSSAPI -QLLL -b #{suffix} \"\(cn=#{nickname}\)\" dn"
    stdout, _stderr, _status = Open3.capture3(cmd)
    stdout.strip.include?(nickname) ? true : false
  end

  def find_ldap_suffix
    cmd = 'ldapsearch -Y GSSAPI -QLLL -b "" -s base "(objectclass=top)" defaultnamingcontext'
    stdout, _stderr, _status = Open3.capture3(cmd)
    stdout.split(':')[-1].strip.to_s
  end

  def file_exists?(file)
    File.file?(file)
  end

  def remove_nickname(nickname, dirs, suffix)
    dirs.each do |dir|
      # remove from nss databases
      cmd = "/usr/bin/certutil -d #{dir} -D -n #{nickname}"
      Open3.capture3(cmd) if match_nickname_in_nss(nickname, dir)
    end
    # remove from the DIT
    cmd = "ldapdelete -Y GSSAPI -Q cn=#{nickname},cn=certificates,cn=ipa,cn=etc,#{suffix}"
    Open3.capture3(cmd) if match_nickname_in_ldap(nickname, suffix)
  end

  def exists?
    nickname = get_nickname(resource[:filepath])
    suffix = find_ldap_suffix
    file_exists?(resource[:filepath]) and match_nickname_in_ldap(nickname, suffix)
  end

  def create
    nickname = get_nickname(resource[:filepath])
    cmd = "/sbin/ipa-cacert-manage install -n #{nickname} -t #{resource[:trustargs]} #{resource[:filepath]}"
    Open3.capture3(cmd)
  end

  def destroy
    dirs = Array[
      '/etc/ipa/nssdb',
      '/etc/pki/pki-tomcat/alias',
      '/etc/dirsrv/slapd-VLAB-OPENVPN-IN',
      '/etc/httpd/alias'
    ]
    nickname = get_nickname(resource[:filepath])
    suffix = find_ldap_suffix
    match_nickname_in_ldap(nickname, suffix) and remove_nickname(nickname, dirs, suffix)
  end
end
