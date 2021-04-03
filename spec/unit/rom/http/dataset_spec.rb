RSpec.describe ROM::HTTP::Dataset do
  subject(:dataset) { ROM::HTTP::Dataset.new(**{ uri: uri }.merge(options)) }

  let(:options) do
    { uri: uri }
  end

  let(:uri) { 'http://localhost:3000' }

  describe '#uri' do
    context 'when no uri configured' do
      specify do
        expect { ROM::HTTP::Dataset.new }.to raise_error(KeyError, /uri/)
      end
    end

    context 'when uri configured' do
      context 'without query_params' do
        let(:options) do
          { uri: uri }
        end

        it 'returns a valid URI with a query' do
          expect(dataset.uri).to eql(URI(uri))
        end
      end

      context 'with query_params' do
        let(:options) do
          { uri: uri, query_params: { username: 'John', role: 'admin' } }
        end

        it 'returns a valid URI with a query' do
          expect(dataset.uri).to eql(URI("#{uri}?username=John&role=admin"))
        end
      end

      context 'with path' do
        context 'without custom base_path' do
          let(:options) { { uri: uri, path: '/users' } }

          it 'returns a valid URI with path appended' do
            expect(dataset.uri).to eql(URI("#{uri}/users"))
          end
        end

        context 'with custom base_path' do
          let(:options) { { uri: uri, base_path: '/blog', path: '/users' } }

          it 'returns a valid URI with base_path and path appended' do
            expect(dataset.uri).to eql(URI("#{uri}/blog/users"))
          end
        end
      end

      context 'with custom base_path' do
        let(:options) { { uri: uri, base_path: 'blog' } }

        it 'returns a valid URI with base path appended' do
          expect(dataset.uri).to eql(URI("#{uri}/blog"))
        end
      end
    end
  end

  describe '#headers' do
    it 'returns empty headers by default' do
      expect(dataset.headers).to eql({})
    end

    context 'with headers configured' do
      let(:headers) { { 'Accept' => 'application/json' } }

      let(:options) do
        { uri: uri, headers: headers }
      end

      it 'returns headers' do
        expect(dataset.headers).to eql(headers)
      end
    end
  end

  describe '#base_path' do
    it 'returns an empty string by default' do
      expect(dataset.base_path).to eql('')
    end

    context 'with base_path option' do
      context 'when base_path is absolute' do
        let(:options) { { uri: uri, base_path: '/users' } }

        it 'removes the leading /' do
          expect(dataset.base_path).to eql('users')
        end
      end

      context 'when base_path is not absolute' do
        let(:options) { { uri: uri, base_path: 'users' } }

        it 'returns provided base path' do
          expect(dataset.base_path).to eql('users')
        end
      end
    end
  end

  describe '#path' do
    subject { dataset.path }

    it 'returns empty path by default' do
      expect(dataset.path).to eql('')
    end

    context 'with base path' do
      let(:options) { { uri: uri, base_path: '/users' } }

      it 'defaults to base_path' do
        expect(dataset.path).to eql('users')
      end
    end

    context 'with path option' do
      context 'when path is absolute' do
        let(:options) { { uri: uri, path: '/users' } }

        it 'removes the leading /' do
          is_expected.to eq('users')
        end
      end

      context 'with base path' do
        let(:options) { { uri: uri, base_path: '/blog', path: '/users' } }

        it 'prepends base path' do
          expect(dataset.path).to eql('blog/users')
        end
      end

      context 'when path is not absolute' do
        context 'with base path' do
          let(:options) { { uri: uri, base_path: '/blog', path: 'users' } }

          it 'prepends base path' do
            expect(dataset.path).to eql('blog/users')
          end
        end
      end
    end
  end

  describe '#absolute_path' do
    it 'returns default path' do
      expect(dataset.absolute_path).to eql('/')
    end

    context 'with path option' do
      context 'when path is absolute' do
        let(:options) { { uri: uri, path: '/users' } }

        it 'returns a valid absolute path' do
          expect(dataset.absolute_path).to eql('/users')
        end
      end

      context 'when path is absolute' do
        let(:options) { { uri: uri, path: 'users' } }

        it 'returns a valid absolute path' do
          expect(dataset.absolute_path).to eql('/users')
        end
      end
    end
  end

  describe '#get?' do
    it 'returns true when request method is set to :get' do
      expect(dataset).to be_get
    end

    it 'returns false when request method is not set to :get' do
      expect(dataset.with_request_method(:put)).to_not be_get
    end
  end

  describe '#post?' do
    it 'returns true when request method is set to :post' do
      expect(dataset.with_request_method(:post)).to be_post
    end

    it 'returns false when request method is not set to :post' do
      expect(dataset.with_request_method(:put)).to_not be_post
    end
  end

  describe '#put?' do
    it 'returns true when request method is set to :put' do
      expect(dataset.with_request_method(:put)).to be_put
    end

    it 'returns false when request method is not set to :put' do
      expect(dataset.with_request_method(:get)).to_not be_put
    end
  end

  describe '#delete?' do
    it 'returns true when request method is set to :delete' do
      expect(dataset.with_request_method(:delete)).to be_delete
    end

    it 'returns false when request method is not set to :delete' do
      expect(dataset.with_request_method(:get)).to_not be_delete
    end
  end

  describe '#request_method' do
    it 'returns default method' do
      expect(dataset).to be_get
    end

    context 'with request_method option' do
      let(:options) { { uri: uri, request_method: :put } }

      it 'returns provided method' do
        expect(dataset).to be_put
      end
    end
  end

  describe '#query_params' do
    it 'returns empty query_params by default' do
      expect(dataset.query_params).to eql({})
    end

    context 'with query_params option' do
      let(:options) { { uri: uri, query_params: { name: 'Jack' } } }

      it 'returns provided query_params' do
        expect(dataset.query_params).to eql(name: 'Jack')
      end
    end
  end

  describe '#body_params' do
    it 'returns empty body_params by default' do
      expect(dataset.body_params).to eql({})
    end

    context 'with body_params option' do
      let(:options) { { uri: uri, body_params: { name: 'Jack' } } }

      it 'returns provided body_params' do
        expect(dataset.body_params).to eql(name: 'Jack')
      end
    end
  end

  describe '#with_headers' do
    it 'returns a new dataset with provided headers' do
      expect(dataset.with_headers('Accept' => 'application/json').headers).to eql('Accept' => 'application/json')
    end
  end

  describe '#add_header' do
    let(:options) do
      { headers: { 'Accept' => 'application/json' } }
    end

    it 'returns a new dataset with new headers' do
      expect(dataset.add_header('New', 'Header').headers)
        .to eql('Accept' => 'application/json', 'New' => 'Header')
    end
  end

  describe '#with_options' do
    it 'returns a new dataset with new options' do
      expect(dataset.with_options(path: 'foo').path).to eql('foo')
    end
  end

  describe '#with_base_path' do
    it 'returns a new dataset with provided base_path' do
      expect(dataset.with_base_path('/users/tasks').base_path).to eql('users/tasks')
    end
  end

  describe '#with_path' do
    it 'returns a new dataset with provided path' do
      expect(dataset.with_path('users').path).to eql('users')
    end
  end

  describe '#append_path' do
    context 'with base_path' do
      let(:options) { { base_path: '/users' } }

      it 'returns a new dataset with provided path appended to previous path' do
        expect(dataset.append_path('tasks').path).to eql('users/tasks')
      end
    end

    context 'without existing path' do
      it 'returns a new dataset with provided path' do
        expect(dataset.append_path('users').path).to eql('users')
      end
    end

    context 'with existing path' do
      let(:options) { { path: '/users' } }

      it 'returns a new dataset with provided path appended to previous path' do
        expect(dataset.append_path('tasks').path).to eql('users/tasks')
      end
    end
  end

  describe '#with_request_method' do
    it 'returns a new dataset with provided request method' do
      expect(dataset.with_request_method(:put).request_method).to be(:put)
    end
  end

  describe '#with_query_params' do
    it 'returns a new dataset with new query_params' do
      expect(dataset.with_query_params(admin: true).query_params).to eql(admin: true)
    end
  end

  describe '#add_query_params' do
    let(:options) do
      { query_params: { age: 21 } }
    end

    it 'returns a new dataset with query_params appended' do
      expect(dataset.add_query_params(admin: true).query_params).to eql(age: 21, admin: true)
    end
  end

  describe '#with_body_params' do
    it 'returns a new dataset with new body_params' do
      expect(dataset.with_body_params(admin: true).body_params).to eql(admin: true)
    end
  end

  describe '#add_body_params' do
    let(:options) do
      { body_params: { age: 21 } }
    end

    it 'returns a new dataset with body_params appended' do
      expect(dataset.add_body_params(admin: true).body_params).to eql(age: 21, admin: true)
    end
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
    let(:attributes) { { user: { name: name } } }
    let(:new_dataset) { double(ROM::HTTP::Dataset) }
    let(:response) { double }

    before do
      allow(dataset).to receive(:with_options).and_return(new_dataset)
      allow(new_dataset).to receive(:response).and_return(response)
    end

    subject! { dataset.insert(attributes) }

    it do
      expect(dataset).to have_received(:with_options).with(
        request_method: :post,
        body_params: attributes
      )
    end
    it { expect(new_dataset).to have_received(:response) }
    it { is_expected.to eq(response) }
  end

  describe '#update' do
    let(:name) { 'Jill' }
    let(:attributes) { { user: { name: name } } }
    let(:new_dataset) { double(ROM::HTTP::Dataset) }
    let(:response) { double }

    before do
      allow(dataset).to receive(:with_options).and_return(new_dataset)
      allow(new_dataset).to receive(:response).and_return(response)
    end

    subject! { dataset.update(attributes) }

    it do
      expect(dataset).to have_received(:with_options).with(
        request_method: :put,
        body_params: attributes
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
    let(:options) do
      { request_handler: request_handler,
        response_handler: response_handler,
        path: 'test',
        query_params: { ok: true } }
    end

    let(:request_handler) do
      -> (ds) { ds.query_params }
    end

    let(:response_handler) do
      -> (response, ds) { [response[:ok], ds.path] }
    end

    it 'issues a request via request handler and handles response via response handler' do
      expect(dataset.response).to eql([true, 'test'])
    end
  end
end
