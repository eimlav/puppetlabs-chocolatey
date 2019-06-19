RSpec.shared_context 'backup and reset config' do
  before(:all) { backup_config }
  after(:all) { reset_config }
end