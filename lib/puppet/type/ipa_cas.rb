# coding: utf-8
Puppet::Type.newtype(:ipa_cas) do
  @doc = 'Manage 3rd party CA certificates in FreeIPA'
  ensurable
  
  newparam(:name, :namevar => true) do
    desc 'Name of the resource'
    validate do |value|
      raise('%s is not a valid string' % value) unless value.is_a?(String)
    end
  end
  
  newparam(:certdir) do
    Puppet.debug(:certdir)
    desc 'Directory for the CA certs'
    validate do |value|
      raise("%s is not a valid directory" % value) unless Puppet::Util.absolute_path?(value)
    end
  end

  newparam(:sourcehash) do
    desc 'Sourcehash where keys point to sources to retrieve the CA certs'
    validate do |value|
      raise('%s is not a valid hash' % value) unless value.is_a?(Hash)
    end
  end

  newparam(:nickname) do
    desc 'Nickname in NSS database for the certificate'
    defaultto :filename
    newvalues(:subject, :filename)
  end
end
