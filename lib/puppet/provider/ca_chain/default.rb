Puppet::Type.type(:ca_chain).provide(:ruby) do
  #require 'fileutils'
  #require 'net/http'
  #require 'uri'

  confine :kernel => :linux

  def exists?
    File.exist?(resource[:file]) || false
  end

  def create
    File.open(resource[:file], "a") { |f|
      resource[:sourcehash].each do |key, value|
        sourcefile = resource[:dir] + '/' + value.split('/')[-1]
        File.foreach(sourcefile) { |line|
          result = line[-1] == "\n" ? line : line << "\n"
          f.write(result)
        }
      end
    }
  end
  
  def destroy
    File.delete(resource[:file]) if File.exist?(resource[:file])
  end
end
