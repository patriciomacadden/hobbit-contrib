require 'helper'

scope 'when inheriting from parent app' do
  ParentError = Class.new StandardError
  ChildError = Class.new StandardError
  UnknownError = Class.new StandardError

  setup do
    class ParentApp < Hobbit::Base
      include Hobbit::ErrorHandling

      error ParentError do
        exception = env['hobbit.error']
        exception.message
      end
    end

    class ChildApp < ParentApp
      error ChildError do
        exception = env['hobbit.error']
        exception.message
      end

      get '/' do
        'hello'
      end

      get '/raise' do
        raise ParentError
      end

      get '/raise_child' do
        raise ChildError
      end

      get '/uncaught_raise' do
        raise UnknownError
      end
    end

    @app = ChildApp.new
  end

  scope 'when does not raise exception' do
    test 'works as expected' do
      get '/'
      assert last_response.ok?
      assert_equal 'hello', last_response.body
    end
  end

  scope 'when raises exception class known to parent' do
    test 'calls the block set in error' do
      get '/raise'
      assert last_response.ok?
      assert_equal 'ParentError', last_response.body
    end
  end

  scope 'when raises exception class known to child' do
    test 'calls the block set in error' do
      get '/raise_child'
      assert last_response.ok?
      assert_equal 'ChildError', last_response.body
    end
  end

  scope 'when raises unknown exception class' do
    it 'does not halt default propogation of the unknown class' do
      assert_raises UnknownError do
        get '/uncaught_raise'
      end
    end
  end
end
