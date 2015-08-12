RSpec.shared_context 'users and tasks' do
  include_context 'setup'

  before do
    gateway = setup.default

    gateway.dataset(:users)
    gateway.dataset(:tasks)
  end
end
