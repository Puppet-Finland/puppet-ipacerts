Puppet::Type.type(:ca_chain).provide(:ruby) do
  require 'fileutils'
  require 'net/http'
  require 'uri'

  confine :kernel => :linux

  def exists?
    File.exist?(resource[:file]) || false
  end

  def create
    File.open(resource[:file], "a") { |f|
      resource[:sourcehash].each do |key, value|
        uri = URI(value)
        begin
          response = Net::HTTP.get_response(uri)
          Puppet.debug(response.body.inspect)
          response.is_a?(Net::HTTPSuccess)
          result = response.body[-1] == "\n" ? response.body : response.body << "\n"
          f.write(result)
        rescue Puppet::ExecutionFailure => e
        end
      end
    }
  end
  
  def destroy
    File.delete(resource[:file]) if File.exist?(resource[:file])
  end
end
