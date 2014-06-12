require 'helper'

scope Hobbit::Environment do
  setup do
    mock_app do
      include Hobbit::Environment
    end
  end

  def with_env(environment)
    env, ENV['RACK_ENV'] = ENV['RACK_ENV'], environment
    yield
    ENV['RACK_ENV'] = env
  end

  scope '::environment' do
    test 'returns the current environment' do
      with_env('development') do
        assert_equal :development, app.to_app.class.environment
      end
    end
  end

  scope '#environment' do
    test 'returns the current environment' do
      with_env('development') do
        assert_equal :development, app.to_app.environment
      end
    end
  end

  scope '::development?' do
    test "returns true if ENV['RACK_ENV'] = :development" do
      with_env('development') do
        assert app.to_app.class.development?
      end
    end

    test "returns false if ENV['RACK_ENV'] != :development" do
      assert !app.to_app.class.development?
    end
  end

  scope '#development?' do
    test "returns true if ENV['RACK_ENV'] = :development" do
      with_env('development') do
        assert app.to_app.development?
      end
    end

    test "returns false if ENV['RACK_ENV'] != :development" do
      assert !app.to_app.development?
    end
  end

  scope '::production?' do
    test "returns true if ENV['RACK_ENV'] = :production" do
      with_env('production') do
        assert app.to_app.class.production?
      end
    end

    test "returns false if ENV['RACK_ENV'] != :production" do
      assert !app.to_app.class.production?
    end
  end

  scope '#production?' do
    test "returns true if ENV['RACK_ENV'] = :production" do
      with_env('production') do
        assert app.to_app.production?
      end
    end

    test "returns false if ENV['RACK_ENV'] != :production" do
      assert !app.to_app.production?
    end
  end

  scope '::test?' do
    test "returns true if ENV['RACK_ENV'] = :test" do
      assert app.to_app.class.test?
    end

    test "returns false if ENV['RACK_ENV'] != :test" do
      with_env('development') do
        assert !app.to_app.class.test?
      end
    end
  end

  scope '#test?' do
    test "returns true if ENV['RACK_ENV'] = :test" do
      assert app.to_app.test?
    end

    test "returns false if ENV['RACK_ENV'] != :test" do
      with_env('development') do
        assert !app.to_app.test?
      end
    end
  end
end
