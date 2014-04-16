require 'minitest_helper'

describe 'combine Hobbit::ErrorHandling and Hobbit::Filter' do
  include Hobbit::Contrib::Mock
  include Rack::Test::Methods

  describe 'when the exception ocurrs in a route' do
    let :app do
      mock_app do
        include Hobbit::Filter
        include Hobbit::ErrorHandling

        error Exception do
          exception = env['hobbit.error']
          exception.message
        end

        before do
          env['hobbit.before'] = 'this is before'
        end

        after do
          env['hobbit.after'] = 'this is after'
        end

        get '/' do
          raise Exception, 'Sorry'
        end
      end
    end

    it 'must call the before filter' do
      get '/'
      last_response.must_be :ok?
      last_response.body.must_equal 'Sorry'
      last_request.env.must_include 'hobbit.before'
      last_request.env.wont_include 'hobbit.after'
    end
  end

  describe 'when the exception ocurrs in a before filter' do
    let :app do
      mock_app do
        include Hobbit::Filter
        include Hobbit::ErrorHandling

        error Exception do
          exception = env['hobbit.error']
          exception.message
        end

        before do
          raise Exception, 'Sorry'
        end

        after do
          env['hobbit.after'] = 'this is after'
        end

        get '/' do
          'this wont be the body'
        end
      end
    end

    it 'must call the before filter' do
      get '/'
      last_response.must_be :ok?
      last_response.body.must_equal 'Sorry'
      last_request.env.wont_include 'hobbit.after'
    end
  end

  describe 'when the exception ocurrs in an after filter' do
    let :app do
      mock_app do
        include Hobbit::Filter
        include Hobbit::ErrorHandling

        error Exception do
          exception = env['hobbit.error']
          exception.message
        end

        before do
          env['hobbit.before'] = 'this is before'
        end

        after do
          raise Exception, 'Sorry'
        end

        get '/' do
          'this is written in the body. '
        end
      end
    end

    it 'must call the before filter' do
      get '/'
      last_response.must_be :ok?
      last_response.body.must_equal 'this is written in the body. Sorry'
      last_request.env.must_include 'hobbit.before'
    end
  end

  describe 'the order of the modules inclusion matters' do
    describe 'when ErrorHandling is included before Filter' do
      let :app do
        mock_app do
          include Hobbit::ErrorHandling
          include Hobbit::Filter

          error Exception do
            exception = env['hobbit.error']
            exception.message
          end

          before do
            env['hobbit.before'] = 'this is before'
          end

          after do
            env['hobbit.after'] = 'this is after'
          end

          get '/' do
            raise Exception, 'Sorry'
          end
        end
      end

      it 'wont work as expected' do
        get '/'
        last_response.must_be :ok?
        last_response.body.must_equal 'Sorry'
        last_request.env.must_include 'hobbit.before'
        # this is contrary to a previous test, which is not the desired workflow
        # or is it?
        last_request.env.must_include 'hobbit.after'
      end
    end
  end
end
