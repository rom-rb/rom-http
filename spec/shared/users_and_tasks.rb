RSpec.shared_context 'users and tasks' do
  include_context 'setup'

  subject(:rom) { setup.finalize }

  before do
    gateway = setup.default

    gateway.dataset(:users)
    gateway.dataset(:tasks)
  end
end
