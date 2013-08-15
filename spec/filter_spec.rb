require 'minitest_helper'

describe Hobbit::Filter do
  include Hobbit::Contrib::Mock
  include Rack::Test::Methods

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

  it 'must call before and after filters' do
    get '/'
    last_response.must_be :ok?
    last_request.env.must_include 'hobbit.before'
    last_request.env['hobbit.before'].must_equal 'this is before'
    last_request.env.must_include 'hobbit.after'
    last_request.env['hobbit.after'].must_equal 'this is after'
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
end
