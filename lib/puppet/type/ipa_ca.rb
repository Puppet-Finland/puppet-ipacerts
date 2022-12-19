# coding: utf-8

module Puppet
  Type.newtype(:ipa_ca) do

    @doc = 'Manage 3rd party CA certificate in FreeIPA'

    ensurable do

      desc 'Create or remove the CA cert.'
      
      newvalue(:present) do
        provider.create
      end
      
      newvalue(:absent) do
        provider.destroy
      end

      defaultto :present
    end

    newparam(:name, namevar: true) do
      desc 'The CA cert name'
      validate do |value|
        raise("%s is not an string" % value) unless value.is_a?(String)
      end
    end
    
    newparam(:filepath) do
      desc 'Filepath for the CA cert'
      validate do |value|
        raise("%s is not an absolute path" % value) unless Puppet::Util.absolute_path?(value)
      end
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
        raise("%s is not a string" % value) unless value.is_a?(String)
      end
    end
  end
end
