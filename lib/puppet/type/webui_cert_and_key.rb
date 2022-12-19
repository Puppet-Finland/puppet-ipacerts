# frozen_string_literal: true

# Manage ipa webui keys and certs
module Puppet
  Type.newtype(:webui_cert_and_key) do
    @doc = 'Manage 3rd party cert and key for IPA webui'

    ensurable do
      desc 'Create or remove the key and the cert'
      newvalue(:present) do
        provider.create
      end

      newvalue(:absent) do
        provider.destroy
      end

      defaultto :present
    end

    newparam(:name, namevar: true) do
      desc 'The name for the resource'
      validate do |value|
        raise('%s is not an string' % value) unless value.is_a?(String)
      end
    end

    newparam(:keyfile) do
      desc 'Filepath for the key'
      validate do |value|
        raise('%s is not an absolute path' % value) unless Puppet::Util.absolute_path?(value)
      end
    end

    newparam(:certfile) do
      desc 'Filepath for the cert'
      validate do |value|
        raise('%s is not an absolute path' % value) unless Puppet::Util.absolute_path?(value)
      end
    end

    newparam(:dir) do
      desc 'Directory of the nss database'
      validate do |value|
        raise('%s is not an absolute path' % value) unless Puppet::Util.absolute_path?(value)
      end
    end

    newparam(:nickname) do
      desc 'Nickname for the certificate'
      validate do |value|
        raise('%s is not an string' % value) unless value.is_a?(String)
      end
    end
  end
end
