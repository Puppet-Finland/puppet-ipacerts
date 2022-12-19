# coding: utf-8

#require 'pathname'

Puppet::Type.newtype(:ca_chain) do

  @doc = 'Manage certificate bundle file'
  ensurable

  newparam(:file, :namevar => true) do
    desc 'Destination bundle file'
    validate do |value|
      raise('file must be a valid absolute path') unless Puppet::Util.absolute_path?(value)
    end
  end

  newparam(:sourcehash) do
    desc 'Sourcehash where keys point to sources to retrieve the CA certs'
    validate do |value|
      raise('%s is not a valid hash' % value) unless value.is_a?(Hash)
    end
  end

  newparam(:dir) do
    desc 'Directory of the source CAs'
    validate do |value|
      raise('%s is not an absolute path' % value) unless Puppet::Util.absolute_path?(value)
    end
  end
end
