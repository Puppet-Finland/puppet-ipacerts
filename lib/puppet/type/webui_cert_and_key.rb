# coding: utf-8
Puppet::Type.newtype(:webui_cert_and_key) do  

  @doc = 'Manage 3rd party FreeIPA cert'
  
  ensurable

  newparam(:name, :namevar => true) do
    desc "Nickname for the 3rdparty cert"
    validate do |value|
    end
  end

  newparam(:key_source) do
    desc "Source to retrieve the private key"
    validate do |value|
      fail("%s is not a valid absolute path" % value) unless Puppet::Util.absolute_path?(value)
    end
  end

  newparam(:cert_source) do
    desc "Source to retrieve the signed ertificate"
    validate do |value|
      fail("%s is not a valid absolute path" % value) unless Puppet::Util.absolute_path?(value)
    end
  end

  newparam(:nss_pwfile) do
    desc "Absolute path to the NSS passord file"
    validate do |value|
      fail("%s is not a valid absolute path" % value) unless Puppet::Util.absolute_path?(value)
    end
  end

end
