Puppet::Type.type(:ipa_cas).provide(:ruby) do

  require 'fileutils'
  require 'net/http'
  require 'uri'

  confine :kernel => :linux

  def exists?
  end

  def create
  end
  
  def destroy
  end

end
