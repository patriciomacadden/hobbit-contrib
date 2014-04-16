require 'minitest_helper'

describe Hobbit::Render do
  include Hobbit::Contrib::Mock
  include Rack::Test::Methods

  def app
    mock_app do
      include Hobbit::Render

      def views_path
        File.expand_path '../fixtures/render/views/', __FILE__
      end

      def name
        'Hobbit'
      end

      get('/') { render 'index' }
      get('/partial') { partial 'partial' }
      get('/using-context') { render 'hello' }
      get('/without-layout') { render '_partial', {}, layout: false }
    end
  end

  describe '#default_layout' do
    it 'defaults to application.erb' do
      app.to_app.default_layout.must_equal "#{app.to_app.layouts_path}/application.erb"
    end
  end

  describe '#find_template' do
    it 'must return a template path' do
      app.to_app.find_template('index').must_equal "#{app.to_app.views_path}/index.#{app.to_app.template_engine}"
    end
  end

  describe '#layouts_path' do
    it 'must return the path to the layouts directory' do
      app.to_app.layouts_path.must_equal "#{app.to_app.views_path}/layouts"
    end
  end

  describe '#partial' do
    it 'must render a template without a layout' do
      get '/partial'
      last_response.must_be :ok?
      last_response.body.wont_match /From application.erb/
      last_response.body.must_match /Hello World!/
    end
  end

  describe '#render' do
    it 'must render a template (using a layout)' do
      get '/'
      last_response.must_be :ok?
      last_response.body.must_match /From application.erb/
      last_response.body.must_match /Hello World!/
    end

    it 'must render a template (not using a layout)' do
      get '/without-layout'
      last_response.must_be :ok?
      last_response.body.wont_match /From application.erb/
      last_response.body.must_match /Hello World!/
    end

    it 'must render a template using the app as context' do
      get '/using-context'
      last_response.must_be :ok?
      last_response.body.must_match /From application.erb/
      last_response.body.must_match /Hello Hobbit!/
    end
  end

  describe '#template_engine' do
    it 'defaults to erb' do
      app.to_app.template_engine.must_equal 'erb'
    end
  end

  describe '#views_path' do
    it 'must return the path to the views directory' do
      app.to_app.views_path.must_equal File.expand_path('../fixtures/render/views', __FILE__)
    end

    it 'defaults to "views"' do
      a = mock_app do
        include Hobbit::Render
      end

      a.to_app.views_path.must_equal 'views'
    end
  end
end
