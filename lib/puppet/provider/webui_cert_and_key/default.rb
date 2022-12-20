# frozen_string_literal: true

Puppet::Type.type(:webui_cert_and_key).provide(:ruby) do

  confine osfamily: :redhat

  def match_nickname_in_nss(dir, nickname)
    cmd = "/usr/bin/certutil -d #{dir} -L"
    stdout, _stderr, _status = Open3.capture3(cmd)
    stdout.include?(nickname) ? true : false
  end

  def file_exists?(file)
    File.file?(file)
  end

  def remove_nickname_in_nss(dir, nickname)
    cmd = "/usr/bin/certutil -F -d #{dir} -n #{nickname} -f #{dir}/pwdfile.txt"
    Open3.capture3(cmd)
  end

  def generate_pkcs12(certfile, keyfile, dir, nickname)
    cmd = "/usr/bin/openssl pkcs12 -export -in #{certfile} -inkey #{keyfile} -password 'file:#{dir}/pwdfile.txt' -out '#{dir}/#{nickname}.pkcs12' -name '#{nickname}'"
    Open3.capture3(cmd)
  end

  def import_cert_and_key(dir, certfile, keyfile, nickname)
    pkcs12_file = "#{dir}/#{nickname}.pkcs12"
    generate_pkcs12(certfile, keyfile, dir, nickname) unless file_exists?(pkcs12_file)
    cmd = "pk12util -d #{dir} -i #{pkcs12_file}  -w #{dir}/pwdfile.txt -k #{dir}/pwdfile.txt"
    Open3.capture3(cmd) unless match_nickname_in_nss(dir, nickname)
  end

  def remove_cert_and_key(dir, _certfile, _keyfile, nickname)
    pkcs12_file = "#{dir}/#{nickname}.pkcs12"
    file_exists?(pkcs12_file) and File.delete(pkcs12_file)
    remove_nickname_in_nss(dir, nickname) if match_nickname_in_nss(dir, nickname)
  end

  def exists?
    match_nickname_in_nss(resource[:dir], resource[:nickname])
  end

  def create
    import_cert_and_key(resource[:dir], resource[:certfile], resource[:keyfile], resource[:nickname])
  end

  def destroy
    remove_cert_and_key(resource[:dir], resource[:certfile], resource[:keyfile], resource[:nickname])
  end
end
