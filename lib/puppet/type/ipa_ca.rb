# coding: utf-8
Puppet::Type.newtype(:ipa_ca) do
  @doc = 'Manage 3rd party CA certificate in FreeIPA'
  ensurable

  newparam(:name, :namevar => true) do
    desc 'Name of the CA cert'
  end
  
  newproperty(:file) do
    desc 'File for the CA cert'
    validate do |value|
      raise("%s does not exist" % value) unless File.file?(value)
    end
  end

  newparam(:nickname_by) do
    desc 'Nickname base in NSS database for the certificate'
    defaultto :subject
    newvalues(:subject, :filename)
  end

  newparam(:order) do
    desc 'Ca order in the chain'
    validate do |value|
      raise("%s is not an integer" % value) unless value.is_a?(Integer)
    end
  end

  newparam(:trustargs) do
    Puppet.debug(:trustargs)
    desc 'Trustargs'
    validate do |value|
      raise("%s does not exist" % value) unless value.is_a?(String)
    end
  end
end
