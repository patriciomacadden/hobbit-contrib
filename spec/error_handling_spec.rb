require 'minitest_helper'

describe Hobbit::ErrorHandling do
  include Hobbit::Contrib::Mock
  include Rack::Test::Methods

  class NotFoundException < StandardError ; end

  let(:app) do
    mock_app do
      include Hobbit::ErrorHandling

      error Exception do |exception|
        exception.message
      end

      error NotFoundException do
        'Not Found'
      end

      get '/' do
        'hello'
      end

      get '/raises' do
        'not this'
        raise Exception, 'Exception'
      end

      get '/other_raises' do
        response.write 'not this'
        raise NotFoundException
      end
    end
  end

  describe '::error' do
    specify do
      p = Proc.new { 'error' }
      app = mock_app do
        include Hobbit::ErrorHandling
        error Exception, &p
      end

      app.to_app.class.errors.must_include Exception
      app.to_app.class.errors[Exception].call.must_equal p.call
    end
  end

  describe '::errors' do
    it 'must return a Hash' do
      app.to_app.class.errors.must_be_kind_of Hash
    end
  end

  describe 'when does not raises an exception' do
    it 'must work as expected' do
      get '/'
      last_response.must_be :ok?
      last_response.body.must_equal 'hello'
    end
  end

  describe 'when raises an exception' do
    it 'must call the block set in error' do
      get '/raises'
      last_response.must_be :ok?
      last_response.body.must_equal 'Exception'
    end

    it 'must allow to define more than one exception' do
      get '/other_raises'
      last_response.must_be :ok?
      last_response.body.must_equal 'Not Found'
    end

    it 'must set the returned value of the error block as the body' do
      get '/other_raises'
      last_response.must_be :ok?
      last_response.body.must_equal 'Not Found'
      last_response.body.wont_equal 'not this'
    end

    it 'must override a previous block if a new one is passed' do
      app.to_app.class.error Exception do
        'other handler!'
      end

      get '/raises'
      last_response.must_be :ok?
      last_response.body.must_equal 'other handler!'
    end
  end
end
