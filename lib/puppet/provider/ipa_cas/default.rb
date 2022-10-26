Puppet::Type.type(:ipa_cas).provide(:ruby) do
  require 'fileutils'
  require 'net/http'
  require 'uri'

  confine :kernel => :linux

  def exists?
    nil
  end

  def create
    nil
  end

  def destroy
    nil
  end
end
