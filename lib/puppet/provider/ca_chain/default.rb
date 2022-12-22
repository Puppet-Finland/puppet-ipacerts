Puppet::Type.type(:ca_chain).provide(:ruby) do
  confine kernel: :linux

  def exists?
    File.exist?(resource[:file]) || false
  end

  def create
    File.open(resource[:file], 'a') do |f|
      resource[:sourcehash].each do |_key, value|
        sourcefile = resource[:dir] + '/' + value.split('/')[-1]
        File.foreach(sourcefile) do |line|
          result = line[-1] == "\n" ? line : line << "\n"
          f.write(result)
        end
      end
    end
  end

  def destroy
    File.delete(resource[:file]) if File.exist?(resource[:file])
  end
end
