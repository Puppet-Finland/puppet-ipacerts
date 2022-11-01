Puppet::Type.type(:ipa_cas).provide(:ruby) do
  require 'fileutils'
  require 'net/http'
  require 'uri'
  require 'open3'
  require 'openssl'

  confine :osfamily => :redhat

  commands :rpm => 'rpm'
  commands :certutil => 'certutil'
  
  # Don't bother if ipa-server package is not installed
  confine :true => begin rpm('-q', 'ipa-server') end

  def exists?
    # The strategy is to match all CA certs as a unit
    # if a CA cert is already properly installed with ipa-cacert-manage, it exists in:
    # /etc/ipa/nssdb/
    # /etc/pki/pki-tomcat/alias/
    # /etc/dirsrv/slapd-VLAB-OPENVPN-IN/
    # /etc/httpd/alias/
    # Just checking one of these is enough 
    nicknames, matches = Array.new, Array.new
    nicknames = collect_nicknames(resource[:sourcehash], resource[:nickname], resource[:certdir])
    matches = collect_matches(nicknames)
    #nicknames.each { |nickname|
    #  if matches.include?(nickname)
    #    Puppet.debug("%s IN MATCHES" % nickname)
    #  end
    #}
    #Puppet.debug("nicknames: %s" % nicknames) unless nicknames.empty?
    #Puppet.debug("matches: %s" % matches) unless nicknames.empty?
    
    #nicknames.each { | nickname |
    #  Puppet.debug("nickname: %s" % nickname)
    #}
    #matches.each { | match |
    #  Puppet.debug("found match: %s" % match)
    #}
  end

  def create
    # loop through hash values in key order
    # the filename is a value split after the last '/'
    # does the file exist?
    # if it does retrieve the file in a temporary file
    # if the temporary file is not the same as the current, overwrite it
    # if the does not exits, retrieve it and store it in the destdir
    # if nickame is chosen to be filename, get the value split after the last '/'
    # if nickname is chosen to be subject, get the subject of the stored file, check for it's existense in nss and return true or false
    # do ipa-cacert-manage to install it with the chosen nickname
    # do ipa-certupdate and check the return value, do error checking and error
    nil
  end

  def destroy
    # remove all of the nicknames in all nss databases
    # /etc/ipa/nssdb
    # /etc/pki/pki-tomcat/alias/
    # /etc/dirsrv/slapd-VLAB-OPENVPN-IN/
    nss_dirs=Array.new('/etc/ipa/nssdb', '/etc/pki/pki-tomcat/alias', '/etc/dirsrv/slapd-VLAB-OPENVPN-IN', '/etc/httpd/alias')
    nicknames = collect_nicknames(resource[:sourcehash], resource[:nickname], resource[:certdir])
    remove_nicknames(nicknames)
    nil
  end

  # returns array
  def collect_nicknames(sourcehash, nickname, certdir)

    Puppet.debug('in collect_nicknames')
    _nicknames = Array.new
    sourcehash.keys.each { | key |
      if nickname.to_s == 'filename'
        name = certdir + "/" + sourcehash[key].split('/')[-1].split('.')[0].to_s
        Puppet.debug(name)
        _nicknames << name
      else
        file = certdir + '/' + sourcehash[key].split('/')[-1]
        Puppet.debug("cert file: %s" % file)
        _nicknames <<  OpenSSL::X509::Certificate.new(File.open(file)).subject.to_s
        Puppet.debug(OpenSSL::X509::Certificate.new(File.open(file)).subject.to_s)
      end
      Puppet.debug("the type of _nicknames before returning it is:  %s" % _nicknames.class)
    }
    return _nicknames
  end

  # returns array
  def collect_matches(nicknames)

    Puppet.debug('in collect_matches')
    cmd='/bin/certutil -d /etc/ipa/nssdb -L'
    matches = Array.new
    nicknames.each { | nickname |
      Puppet.debug('looking for nickname %s' % nickname )
      Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
        while line = stdout.gets
          if line.match(/(#{nickname})/)
            matches << nickname.to_s
            break
          end
        end
      end
    }
    Puppet.debug("the type of matches before returning it is:  %s" % matches.class)
    return matches
  end

  def install_ca_cert(nickname, destdir, filename)

    Puppet.debug('in install_cac_cert')
    # if changes, update ipa
    # update_ipa()
    nil
  end

  def update_ipa()
    Puppet.debug('in update_ipa')
    cmd = 'ipa-cert-update -v'
    Open3.popen3(cmd) do | stdin, stdout, stderr, wait_thr |
      pid = wait_thr.pid
      exit_status = wait_thr.value
    end
  end
end


