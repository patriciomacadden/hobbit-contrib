require 'minitest_helper'

describe Hobbit::EnhancedRender do
  include Hobbit::Contrib::Mock
  include Rack::Test::Methods

  def app
    mock_app do
      include Hobbit::EnhancedRender

      # we do this because it the layout path is relative to file being run
      def layout_path(template)
        File.expand_path("../fixtures/#{super}", __FILE__)
      end

      # we do this because it the view path is relative to file being run
      def view_path(template)
        File.expand_path("../fixtures/#{super}", __FILE__)
      end

      get '/' do
        render 'index', {}, layout: 'layout'
      end

      get '/without-layout' do
        render 'index'
      end

      get '/partial' do
        partial 'partial'
      end
    end
  end

  describe '#layout_path' do
    it 'must return a path' do
      path = File.expand_path('../fixtures/views/layouts/layout.erb', __FILE__)
      app.to_app.layout_path('layout').must_equal path
    end
  end

  describe '#partial' do
    it 'must render' do
      get '/partial'
      last_response.must_be :ok?
      last_response.body.wont_match /From layout.erb/
      last_response.body.wont_match /From index.erb/
      last_response.body.must_match /From _partial.erb/
    end
  end

  describe '#render' do
    it 'must render with a layout' do
      get '/'
      last_response.must_be :ok?
      last_response.body.must_match /From layout.erb/
      last_response.body.must_match /From index.erb/
      last_response.body.must_match /From _partial.erb/
    end

    it 'must render without a layout' do
      get '/without-layout'
      last_response.must_be :ok?
      last_response.body.wont_match /From layout.erb/
      last_response.body.must_match /From index.erb/
      last_response.body.must_match /From _partial.erb/
    end
  end

  describe '#template_engine' do
    it 'must be erb by default' do
      app.to_app.template_engine.must_equal 'erb'
    end
  end

  describe '#view_path' do
    it 'must return a path' do
      path = File.expand_path('../fixtures/views/index.erb', __FILE__)
      app.to_app.view_path('index').must_equal path
    end
  end
end