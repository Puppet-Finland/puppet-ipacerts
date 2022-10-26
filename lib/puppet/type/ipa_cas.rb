# coding: utf-8
Puppet::Type.newtype(:ipa_cas) do  

  @doc = 'Manage 3rd party CA certificates in FreeIPA'
  
  ensurable

  newparam(:sourcehash, :namevar => true) do
    desc "Sourcehash where keys point to sources to retrieve the CA certs"
    validate do |value|
      fail("%s is not a valid hash" % value) unless value.is_a?(Hash)
    end
  end

  newparam(:destdir) do
    desc "Destination for the file ca files"
    validate do |value|
      fail("%s is not a valid absolute path" % value) unless Puppet::Util.absolute_path?(value)
    end
  end

end
