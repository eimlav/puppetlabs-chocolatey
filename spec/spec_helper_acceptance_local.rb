require 'net/http'
require 'nokogiri'

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

CHOCOLATEY_LATEST_INFO_URL = 'https://artifactory.delivery.puppetlabs.net/artifactory/api/nuget/choco-pipeline-tests/Packages()?$filter=((Id%20eq%20%27chocolatey%27)%20and%20(not%20IsPrerelease))%20and%20IsLatestVersion'.freeze

def encode_command(cmd)
  cmd = cmd.chars.to_a.join("\x00").chomp
  cmd << "\x00" unless cmd[-1].eql? "\x00"
  # use strict_encode because linefeeds are not correctly handled in our model
  cmd = Base64.strict_encode64(cmd).chomp
  cmd
end

def install_chocolatey
  chocolatey_pp = <<-MANIFEST
    include chocolatey
  MANIFEST

  apply_manifest(chocolatey_pp, expect_failures: true)
end

def config_file_location
  'c:\\ProgramData\\chocolatey\\config\\chocolatey.config'
end

def backup_config
  backup_command = <<-COMMAND
  if (Test-Path #{config_file_location}) {
    Copy-Item -Path #{config_file_location} -Destination #{config_file_location}.bkp
  }
  COMMAND

  run_shell(backup_command)
end

def reset_config
  backup_command = <<-COMMAND
  if (Test-Path #{config_file_location}.bkp) {
    Move-Item -Path #{config_file_location}.bkp -Destination #{config_file_location} -force
  }
  COMMAND

  run_shell(backup_command, catch_failures: true)
end

def get_xml_value(xpath, file_text)
  doc = Nokogiri::XML(file_text)

  doc.xpath(xpath)
end

def config_content_command
  "cmd.exe /c \"type #{config_file_location}\""
end

RSpec.configure do |c|
  c.include_context 'backup and reset config', include_shared: true
  c.before(:suite) { install_chocolatey }
end
