require 'spec_helper_acceptance'
require 'pry'

describe 'chocolateyfeature resource' do

  context 'disable a disabled chocolateyfeature' do
    include_context 'backup and reset config'

    let(:pp_chocolateyfeature) do
      <<-MANIFEST
        chocolateyfeature {'failOnAutoUninstaller':
          ensure => disabled,
        }
      MANIFEST
    end

    it 'applies manifest' do
      idempotent_apply(pp_chocolateyfeature)
    end

    it 'chocolateyfeature remains disabled' do
      run_shell(config_content_command, expect_failures: true) do |result|
        expect(result.exit_code).to eq(0)
        expect(get_xml_value("//features/feature[@name='failOnAutoUninstaller']/@enabled", result.stdout).to_s).to match(%r{false})
      end
    end
  end

  context 'disable an enabled chocolateyfeature' do
    include_context 'backup and reset config'

    let(:pp_chocolateyfeature) do
      <<-MANIFEST
        chocolateyfeature { 'checksumFiles':
          ensure => enabled,
        }
      MANIFEST
    end

    let(:pp_chocolateyfeature_disabled) do
      <<-MANIFEST
        chocolateyfeature { 'checksumFiles':
          ensure => disabled,
        }
      MANIFEST
    end

    it 'applies manifest' do
      idempotent_apply(pp_chocolateyfeature)
    end

    it 'enables chocolateyfeature' do
      run_shell(config_content_command, expect_failures: true) do |result|
        expect(result.exit_code).to eq(0)
        expect(get_xml_value("//features/feature[@name='checksumFiles']/@enabled", result.stdout).to_s).to match(%r{true})
      end
    end

    it 'applies manifest' do
      idempotent_apply(pp_chocolateyfeature_disabled)
    end

    it 'disables chocolateyfeature' do
      run_shell(config_content_command, expect_failures: true) do |result|
        expect(result.exit_code).to eq(0)
        expect(get_xml_value("//features/feature[@name='checksumFiles']/@enabled", result.stdout).to_s).to match(%r{false})
      end
    end
  end

  context 'enable a disabled chocolateyfeature' do
    include_context 'backup and reset config'

    let(:pp_chocolateyfeature) do
      <<-MANIFEST
        chocolateyfeature {'failOnAutoUninstaller':
          ensure => disabled,
        }
      MANIFEST
    end

    let(:pp_chocolateyfeature_enabled) do
      <<-MANIFEST
        chocolateyfeature {'failOnAutoUninstaller':
          ensure => enabled,
        }
      MANIFEST
    end

    it 'applies manifest' do
      idempotent_apply(pp_chocolateyfeature)
    end

    it 'disables chocolateyfeature' do
      run_shell(config_content_command, expect_failures: true) do |result|
        expect(result.exit_code).to eq(0)
        expect(get_xml_value("//features/feature[@name='failOnAutoUninstaller']/@enabled", result.stdout).to_s).to match(%r{false})
      end
    end

    it 'applies manifest' do
      idempotent_apply(pp_chocolateyfeature_enabled)
    end
      
    it 'enables chocolateyfeature' do
      run_shell(config_content_command, expect_failures: true) do |result|
        expect(result.exit_code).to eq(0)
        expect(get_xml_value("//features/feature[@name='failOnAutoUninstaller']/@enabled", result.stdout).to_s).to match(%r{true})
      end
    end
  end

  context 'enable enabled chocolateyfeature' do
    include_context 'backup and reset config'

    let(:pp_chocolateyfeature) do
      <<-MANIFEST
        chocolateyfeature {'usePackageExitCodes':
          ensure => enabled,
        }
      MANIFEST
    end

    it 'applies manifest' do
      idempotent_apply(pp_chocolateyfeature)
    end

    it 'enables chocolateyfeature' do
      run_shell(config_content_command, expect_failures: true) do |result|
        expect(result.exit_code).to eq(0)
        expect(get_xml_value("//features/feature[@name='usePackageExitCodes']/@enabled", result.stdout).to_s).to match(%r{true})
      end
    end

    it 'applies manifest' do
      idempotent_apply(pp_chocolateyfeature)
    end

    it 'chocolateyfeature remains enabled' do
      run_shell(config_content_command, expect_failures: true) do |result|
        expect(result.exit_code).to eq(0)
        expect(get_xml_value("//features/feature[@name='usePackageExitCodes']/@enabled", result.stdout).to_s).to match(%r{true})
      end
    end
  end

  context 'enable non-existent chocolateyfeature' do
    include_context 'backup and reset config'

    let(:pp_chocolateyfeature) do
      <<-MANIFEST
        chocolateyfeature {'idontexistfeature123123':
          ensure => enabled,
        }
      MANIFEST
    end
    
    it 'raises error' do
      apply_manifest(pp_chocolateyfeature, :expect_failures => true) do |result|
        expect(result.exit_code).to_not eq(0)
        expect(result.stderr).to match(%r{Feature 'idontexistfeature123123' not found})
      end
    end
  end

  context 'remove chocolateyfeature' do
    include_context 'backup and reset config'

    let(:pp_chocolateyfeature) do
      <<-MANIFEST
        chocolateyfeature {'checksumFiles':
          ensure => absent,
        }
      MANIFEST
    end

    it 'raises error' do
      apply_manifest(pp_chocolateyfeature, :expect_failures => true) do |result|
        expect(result.exit_code).to_not eq(0)
        expect(result.stderr).to match(%r{Error: Parameter ensure failed on Chocolateyfeature\[checksumFiles\]: Invalid value \"absent\"})
      end
    end
  end
end
