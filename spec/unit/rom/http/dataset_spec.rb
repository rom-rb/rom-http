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

  describe '#uri' do
    it { expect(dataset.uri).to eq(uri) }
  end

  describe '#headers' do
    subject { dataset.headers }

    context 'when no headers configured' do
      context 'with no headers option' do
        it { is_expected.to eq({}) }
      end

      context 'with headers option' do
        let(:headers) { { 'Accept' => 'application/json' } }
        let(:options) { { headers: headers } }

        it { is_expected.to eq(headers) }
      end
    end

    context 'when headers configured' do
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

    context 'when no name configured' do
      it { is_expected.to eq('') }
    end

    context 'when name configured' do
      let(:name) { 'users' }
      let(:config) do
        super().merge(name: name)
      end

      it { is_expected.to eq(name) }
    end
  end

  describe '#path' do
    subject { dataset.path }

    context 'when no path option' do
      it { is_expected.to eq('') }
    end

    context 'when path option' do
      let(:path) { 'users' }
      let(:options) { { path: path } }

      it { is_expected.to eq(path) }
    end
  end

  describe '#request_method' do
    subject { dataset.request_method }

    context 'when no request_method option' do
      it { is_expected.to eq(:get) }
    end

    context 'when request_method option' do
      let(:request_method) { :put }
      let(:options) { { request_method: request_method } }

      it { is_expected.to eq(request_method) }
    end
  end

  describe '#params' do
    subject { dataset.params }

    context 'when no params option' do
      it { is_expected.to eq({}) }
    end

    context 'when params option' do
      let(:params) { { name: 'Piotr' } }
      let(:options) { { params: params } }

      it { is_expected.to eq(params) }
    end
  end
end
