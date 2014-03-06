require 'minitest_helper'

describe Hobbit::Filter do
  include Hobbit::Contrib::Mock
  include Rack::Test::Methods

  describe 'basic specs' do
    let(:app) do
      mock_app do
        include Hobbit::Filter

        before do
          env['hobbit.before'] = 'this is before'
        end

        get '/' do
          'GET /'
        end

        after do
          env['hobbit.after'] = 'this is after'
        end
      end
    end

    %w(after before).each do |kind|
      str = <<EOS
    describe '::#{kind}' do
      specify do
        p = Proc.new { 'do something' }
        app = mock_app do
          include Hobbit::Filter
          #{kind}('', &p)
        end

        app.to_app.class.filters[:#{kind}].size.must_equal 1
        app.to_app.class.filters[:#{kind}].first[:block].call.must_equal p.call
      end
    end

    describe 'when a filter matches' do
      it "must call the filters' block" do
        get '/'
        last_response.must_be :ok?
        last_request.env.must_include 'hobbit.#{kind}'
        last_request.env['hobbit.#{kind}'].must_equal 'this is #{kind}'
      end
    end
EOS
      class_eval str
    end

    describe '::filters' do
      it 'must return a Hash' do
        app.to_app.class.filters.must_be_kind_of Hash
      end
    end

    describe '::compile_filter' do
      let(:block) { block = Proc.new { |env| [200, {}, []] } }

      it 'must compile /' do
        path = '/'
        route = app.to_app.class.send :compile_filter, path, &block
        route[:block].call({}).must_equal block.call({})
        route[:compiled_path].to_s.must_equal /^\/$/.to_s
      end

      it 'must compile with .' do
        path = '/route.json'
        route = app.to_app.class.send :compile_filter, path, &block
        route[:block].call({}).must_equal block.call({})
        route[:compiled_path].to_s.must_equal /^\/route.json$/.to_s
      end

      it 'must compile with -' do
        path = '/hello-world'
        route = app.to_app.class.send :compile_filter, path, &block
        route[:block].call({}).must_equal block.call({})
        route[:compiled_path].to_s.must_equal /^\/hello-world$/.to_s
      end

      it 'must compile with params' do
        path = '/hello/:name'
        route = app.to_app.class.send :compile_filter, path, &block
        route[:block].call({}).must_equal block.call({})
        route[:compiled_path].to_s.must_equal /^\/hello\/([^\/?#]+)$/.to_s

        path = '/say/:something/to/:someone'
        route = app.to_app.class.send :compile_filter, path, &block
        route[:block].call({}).must_equal block.call({})
        route[:compiled_path].to_s.must_equal /^\/say\/([^\/?#]+)\/to\/([^\/?#]+)$/.to_s
      end

      it 'must compile with . and params' do
        path = '/route/:id.json'
        route = app.to_app.class.send :compile_filter, path, &block
        route[:block].call({}).must_equal block.call({})
        route[:compiled_path].to_s.must_equal /^\/route\/([^\/?#]+).json$/.to_s
      end
    end

    it 'must call before and after filters' do
      get '/'
      last_response.must_be :ok?
      last_request.env.must_include 'hobbit.before'
      last_request.env['hobbit.before'].must_equal 'this is before'
      last_request.env.must_include 'hobbit.after'
      last_request.env['hobbit.after'].must_equal 'this is after'
    end
  end

  describe 'when multiple filters are declared' do
    let(:app) do
      mock_app do
        include Hobbit::Filter

        before do
          env['hobbit.before'] = 'this will match'
        end

        before '/' do
          env['hobbit.before'] = 'this wont match'
        end

        after do
          env['hobbit.after'] = 'this will match'
        end

        after '/' do
          env['hobbit.after'] = 'this wont match'
        end

        get('/') { 'GET /' }
      end
    end

    it 'must call the first that matches' do
      get '/'
      last_response.must_be :ok?
      last_request.env.must_include 'hobbit.before'
      last_request.env['hobbit.before'].must_equal 'this will match'
      last_request.env.must_include 'hobbit.after'
      last_request.env['hobbit.after'].must_equal 'this will match'
    end
  end

  describe 'when a before filter redirects the response' do
    let :app do
      mock_app do
        include Hobbit::Filter

        before do
          response.redirect '/goodbye' unless request.path_info == '/goodbye'
        end

        get '/' do
          'hello world'
        end

        get '/goodbye' do
          'goodbye world'
        end
      end
    end

    it 'must redirect on before filters' do
      get '/'
      last_response.must_be :redirection?
      follow_redirect!
      last_response.must_be :ok?
      last_response.body.must_match /goodbye world/
    end
  end

  describe 'when halting in a before filter' do
    let :app do
      mock_app do
        include Hobbit::Filter

        before do
          halt 401
        end

        get '/' do
          'hello world'
        end
      end
    end

    it 'wont execute the route' do
      get '/'
      last_response.status.must_equal 401
      last_response.body.must_be :empty?
    end
  end

  describe 'when halting in a route' do
    let :app do
      mock_app do
        include Hobbit::Filter

        before do
          response.headers['Content-Type'] = 'text/plain'
        end

        after do
          response.headers['Content-Type'] = 'application/json'
        end

        get '/' do
          halt 401, 'Unauthenticated'
        end
      end
    end

    it 'wont execute the after filter' do
      get '/'
      last_response.status.must_equal 401
      last_response.headers.must_include 'Content-Type'
      last_response.headers['Content-Type'].must_equal 'text/plain'
      last_response.body.must_equal 'Unauthenticated'
    end
  end

  describe 'when halting in an after filter' do
    let :app do
      mock_app do
        include Hobbit::Filter

        after do
          halt 401
        end

        get '/' do
          'hello world'
        end
      end
    end

    it 'wont execute the route' do
      get '/'
      last_response.status.must_equal 401
      last_response.body.must_equal 'hello world'
    end
  end
end
