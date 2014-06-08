require 'helper'

scope 'combine Hobbit::ErrorHandling and Hobbit::Filter' do
  scope 'when the exception ocurrs in a route' do
    setup do
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

    test 'calls the before filter' do
      get '/'
      assert last_response.ok?
      assert last_response.body == 'Sorry'
      assert last_request.env.include? 'hobbit.before'
      assert !last_request.env.include?('hobbit.after')
    end
  end

  scope 'when the exception ocurrs in a before filter' do
    setup do
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

    test 'calls the before filter' do
      get '/'
      assert last_response.ok?
      assert last_response.body == 'Sorry'
      assert !last_request.env.include?('hobbit.after')
    end
  end

  scope 'when the exception ocurrs in an after filter' do
    setup do
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

    test 'calls the before filter' do
      get '/'
      assert last_response.ok?
      assert last_response.body == 'this is written in the body. Sorry'
      assert last_request.env.include? 'hobbit.before'
    end
  end

  scope 'the order of the modules inclusion matters' do
    scope 'when ErrorHandling is included before Filter' do
      setup do
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

      test 'does not work as expected' do
        get '/'
        assert last_response.ok?
        assert last_response.body == 'Sorry'
        assert last_request.env.include? 'hobbit.before'
        # this is contrary to a previous test, which is not the desired workflow
        # or is it?
        assert last_request.env.include? 'hobbit.after'
      end
    end
  end
end
