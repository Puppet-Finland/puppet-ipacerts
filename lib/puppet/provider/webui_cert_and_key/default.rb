Puppet::Type.type(:webui_cert_and_key).provide(:ruby) do

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
