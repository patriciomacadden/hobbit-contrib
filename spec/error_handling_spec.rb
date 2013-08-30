require 'minitest_helper'

describe Hobbit::ErrorHandling do
  include Hobbit::Contrib::Mock
  include Rack::Test::Methods

  class NotFoundException < Exception ; end
  class SpecificNotFoundException < NotFoundException ; end
  class UnknownException < Exception ; end

  let(:app) do
    mock_app do
      include Hobbit::ErrorHandling

      error NotFoundException do
        'Not Found'
      end

      error StandardError do |exception|
        exception.message
      end


      get '/' do
        'hello'
      end

      get '/raises' do
        'not this'
        raise StandardError, 'StandardError'
      end

      get '/other_raises' do
        response.write 'not this'
        raise NotFoundException
      end

      get '/same_other_raises' do
        response.write 'not this'
        raise SpecificNotFoundException
      end

      get '/uncaught_raise' do
        response.write 'not this'
        raise UnknownException
      end
    end
  end

  describe '::error' do
    specify do
      p = Proc.new { 'error' }
      app = mock_app do
        include Hobbit::ErrorHandling
        error StandardError, &p
      end

      app.to_app.class.errors.must_include StandardError
      app.to_app.class.errors[StandardError].call.must_equal p.call
    end
  end

  describe '::errors' do
    it 'must return a Hash' do
      app.to_app.class.errors.must_be_kind_of Hash
    end
  end

  describe 'when does not raise exception' do
    it 'must work as expected' do
      get '/'
      last_response.must_be :ok?
      last_response.body.must_equal 'hello'
    end
  end

  describe 'when does raise an unknown exception class' do
    it 'must not halt default propagation of the unknown class' do
      proc {get '/uncaught_raise'}.must_raise(UnknownException)
    end
  end

  describe 'when raises an known exception class' do
    it 'must call the block set in error' do
      get '/raises'
      last_response.must_be :ok?
      last_response.body.must_equal 'StandardError'
    end

    it 'must allow to define more than one exception' do
      get '/other_raises'
      last_response.must_be :ok?
      last_response.body.must_equal 'Not Found'
    end

    it 'must allow to define a general exception class to catch' do
      get '/same_other_raises'
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
      app.to_app.class.error StandardError do
        'other handler!'
      end

      get '/raises'
      last_response.must_be :ok?
      last_response.body.must_equal 'other handler!'
    end
  end
end
