RSpec.describe ROM::HTTP::Dataset do
  let(:dataset) { ROM::HTTP::Dataset.new(config, options) }
  let(:config) do
    {
      uri: uri,
      request_handler: request_handler,
      response_handler: response_handler
    }
  end
  let(:options) { {} }
  let(:uri) { 'http://localhost:3000' }
  let(:request_handler) { double(Proc) }
  let(:response_handler) { double(Proc) }

  it { expect(dataset).to be_kind_of(Enumerable) }

  describe 'defaults' do
    describe '#config' do
      subject { dataset.config }

      it { is_expected.to eq(config) }
    end

    describe '#options' do
      subject { dataset.options }

      context 'with options passed' do
        let(:options) do
          {
            request_method: :put,
            headers: {
              'Accept' => 'application/json'
            }
          }
        end

        it do
          is_expected.to eq(
            request_method: :put,
            path: '',
            params: {},
            headers: {
              'Accept' => 'application/json'
            }
          )
        end
      end

      context 'with no options passed' do
        it do
          is_expected.to eq(
            request_method: :get,
            path: '',
            params: {}
          )
        end
      end
    end
  end

  describe '#==' do
    subject { dataset == other }

    context 'with config and options equal' do
      let(:other) { ROM::HTTP::Dataset.new(dataset.config, dataset.options) }

      it { is_expected.to be true }
    end

    context 'with config and options equal' do
      let(:other) do
        ROM::HTTP::Dataset.new(dataset.config, dataset.options.merge(path: Random.new_seed))
      end

      it { is_expected.to be false }
    end
  end

  describe '#uri' do
    it { expect(dataset.uri).to eq(uri) }
  end

  describe '#headers' do
    subject { dataset.headers }

    context 'with no headers configured' do
      context 'with no headers option' do
        it { is_expected.to eq({}) }
      end

      context 'with headers option' do
        let(:headers) { { 'Accept' => 'application/json' } }
        let(:options) { { headers: headers } }

        it { is_expected.to eq(headers) }
      end
    end

    context 'with headers configured' do
      context 'with no headers option' do
        let(:headers) { { 'Accept' => 'application/json' } }
        let(:config) do
          super().merge(headers: headers)
        end

        it { is_expected.to eq(headers) }
      end

      context 'with headers option' do
        let(:config_headers) { { 'Content-Type' => 'application/json' } }
        let(:config) do
          super().merge(headers: config_headers)
        end
        let(:option_headers) { { 'Accept' => 'application/json' } }
        let(:options) { { headers: option_headers } }

        it do
          is_expected.to eq(
            'Content-Type' => 'application/json',
            'Accept' => 'application/json'
          )
        end
      end
    end
  end

  describe '#name' do
    subject { dataset.name }

    context 'with no name configured' do
      it { is_expected.to eq('') }
    end

    context 'with name configured' do
      let(:name) { 'users' }
      let(:config) do
        super().merge(name: name)
      end

      it { is_expected.to eq(name) }
    end
  end

  describe '#path' do
    subject { dataset.path }

    context 'with no path option' do
      it { is_expected.to eq('') }
    end

    context 'with path option' do
      context 'when path is absolute' do
        let(:path) { '/users' }
        let(:options) { { path: path } }

        it 'removes the leading /' do
          is_expected.to eq('users')
        end
      end

      context 'when path is not absolute' do
        let(:path) { 'users' }
        let(:options) { { path: path } }

        it { is_expected.to eq(path) }
      end
    end
  end

  describe '#absolute_path' do
    subject { dataset.absolute_path }

    context 'with no path option' do
      it { is_expected.to eq('/') }
    end

    context 'with path option' do
      context 'when path is absolute' do
        let(:path) { '/users' }
        let(:options) { { path: path } }

        it { is_expected.to eq(path) }
      end

      context 'when path is not absolute' do
        let(:path) { 'users' }
        let(:options) { { path: path } }

        it { is_expected.to eq("/#{path}") }
      end
    end
  end

  describe '#request_method' do
    subject { dataset.request_method }

    context 'with no request_method option' do
      it { is_expected.to eq(:get) }
    end

    context 'with request_method option' do
      let(:request_method) { :put }
      let(:options) { { request_method: request_method } }

      it { is_expected.to eq(request_method) }
    end
  end

  describe '#params' do
    subject { dataset.params }

    context 'with no params option' do
      it { is_expected.to eq({}) }
    end

    context 'with params option' do
      let(:params) { { name: 'Jack' } }
      let(:options) { { params: params } }

      it { is_expected.to eq(params) }
    end
  end

  describe '#with_headers' do
    let(:headers) { { 'Accept' => 'application/json' } }
    let(:new_dataset) { dataset.with_headers(headers) }

    subject! { new_dataset }

    it { expect(new_dataset.config).to eq(config) }
    it do
      expect(new_dataset.options).to eq(
        request_method: :get,
        path: '',
        params: {},
        headers: headers
      )
    end
    it { is_expected.to_not be(dataset) }
    it { is_expected.to be_a(ROM::HTTP::Dataset) }
  end

  describe '#add_header' do
    let(:header_key) { 'Accept' }
    let(:header_value) { 'application/json' }
    let(:new_dataset) { double(ROM::HTTP::Dataset) }

    before do
      allow(dataset).to receive(:with_headers).and_return(new_dataset)
    end

    subject! { dataset.add_header(header_key, header_value) }

    context 'with existing headers configured' do
      let(:config_headers) { { 'Content-Type' => 'application/json', 'Accept' => 'text/html' } }
      let(:config) { super().merge(headers: config_headers) }

      it do
        expect(dataset).to have_received(:with_headers).with(
          'Content-Type' => 'application/json',
          header_key => header_value
        )
      end
      it { is_expected.to eq(new_dataset) }
    end

    context 'without existing headers configured' do
      it do
        expect(dataset).to have_received(:with_headers).with(
          header_key => header_value
        )
      end
      it { is_expected.to eq(new_dataset) }
    end
  end

  describe '#with_options' do
    let(:name) { 'Jill' }
    let(:options) { { params: { name: name } } }
    let(:new_dataset) { dataset.with_options(options) }

    subject! { new_dataset }

    it { expect(new_dataset.config).to eq(config) }
    it do
      expect(new_dataset.options).to eq(
        request_method: :get,
        path: '',
        params: {
          name: name
        }
      )
    end
    it { is_expected.to_not be(dataset) }
    it { is_expected.to be_a(ROM::HTTP::Dataset) }
  end

  describe '#with_path' do
    let(:path) { '/users/tasks' }
    let(:new_dataset) { double(ROM::HTTP::Dataset) }

    before do
      allow(dataset).to receive(:with_options).and_return(new_dataset)
    end

    subject! { dataset.with_path(path) }

    it { expect(dataset).to have_received(:with_options).with(path: path) }
    it { is_expected.to eq(new_dataset) }
  end

  describe '#append_path' do
    let(:path) { 'tasks' }
    let(:new_dataset) { double(ROM::HTTP::Dataset) }

    before do
      allow(dataset).to receive(:with_options).and_return(new_dataset)
    end

    subject! { dataset.append_path(path) }

    context 'without existing path' do
      it { expect(dataset).to have_received(:with_options).with(path: '/tasks') }
      it { is_expected.to eq(new_dataset) }
    end

    context 'with existing path' do
      let(:options) { { path: '/users' } }

      it { expect(dataset).to have_received(:with_options).with(path: '/users/tasks') }
      it { is_expected.to eq(new_dataset) }
    end
  end

  describe '#with_request_method' do
    let(:request_method) { :put }
    let(:new_dataset) { double(ROM::HTTP::Dataset) }

    before do
      allow(dataset).to receive(:with_options).and_return(new_dataset)
    end

    subject! { dataset.with_request_method(request_method) }

    it { expect(dataset).to have_received(:with_options).with(request_method: request_method) }
    it { is_expected.to eq(new_dataset) }
  end

  describe '#with_params' do
    let(:name) { 'Jack' }
    let(:params) { { user: { name: name } } }
    let(:new_dataset) { double(ROM::HTTP::Dataset) }

    before do
      allow(dataset).to receive(:with_options).and_return(new_dataset)
    end

    subject! { dataset.with_params(params) }

    it { expect(dataset).to have_received(:with_options).with(params: params) }
    it { is_expected.to eq(new_dataset) }
  end

  describe '#each' do
    let(:response) { double(Array) }
    let(:block) { proc {} }
    let(:result) { double }

    before do
      allow(dataset).to receive(:response).and_return(response)
      allow(response).to receive(:each).and_yield.and_return(result)
    end

    context 'with no block given' do
      subject! { dataset.each }

      it { expect(dataset).to_not have_received(:response) }
      it { expect(response).to_not have_received(:each) }
      it { is_expected.to be_kind_of(Enumerable) }
    end

    context 'with block given' do
      subject! { dataset.each(&block) }

      it { expect(dataset).to have_received(:response).once }
      it { expect(response).to have_received(:each) }
      it { is_expected.to eq(result) }
    end
  end

  describe '#insert' do
    let(:name) { 'Jill' }
    let(:params) { { user: { name: name } } }
    let(:new_dataset) { double(ROM::HTTP::Dataset) }
    let(:response) { double }

    before do
      allow(dataset).to receive(:with_options).and_return(new_dataset)
      allow(new_dataset).to receive(:response).and_return(response)
    end

    subject! { dataset.insert(params) }

    it do
      expect(dataset).to have_received(:with_options).with(
        request_method: :post,
        params: params
      )
    end
    it { expect(new_dataset).to have_received(:response) }
    it { is_expected.to eq(response) }
  end

  describe '#update' do
    let(:name) { 'Jill' }
    let(:params) { { user: { name: name } } }
    let(:new_dataset) { double(ROM::HTTP::Dataset) }
    let(:response) { double }

    before do
      allow(dataset).to receive(:with_options).and_return(new_dataset)
      allow(new_dataset).to receive(:response).and_return(response)
    end

    subject! { dataset.update(params) }

    it do
      expect(dataset).to have_received(:with_options).with(
        request_method: :put,
        params: params
      )
    end
    it { expect(new_dataset).to have_received(:response) }
    it { is_expected.to eq(response) }
  end

  describe '#delete' do
    let(:new_dataset) { double(ROM::HTTP::Dataset) }
    let(:response) { double }

    before do
      allow(dataset).to receive(:with_options).and_return(new_dataset)
      allow(new_dataset).to receive(:response).and_return(response)
    end

    subject! { dataset.delete }

    it do
      expect(dataset).to have_received(:with_options).with(
        request_method: :delete
      )
    end
    it { expect(new_dataset).to have_received(:response) }
    it { is_expected.to eq(response) }
  end

  describe '#response' do
    let(:response) { double }
    let(:result) { double }

    before do
      allow(request_handler).to receive(:call).and_return(response)
      allow(response_handler).to receive(:call).and_return(result)
    end

    subject! { dataset.response }

    it { expect(request_handler).to have_received(:call).with(dataset) }
    it { expect(response_handler).to have_received(:call).with(response, dataset) }
    it { is_expected.to eq(result) }
  end
end
