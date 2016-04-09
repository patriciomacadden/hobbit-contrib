require 'helper'

scope Hobbit::Mote do
  setup do
    mock_app do
      include Hobbit::Mote

      def views_path
        File.expand_path '../fixtures/mote/views/', __FILE__
      end

      def name
        'Hobbit'
      end

      get('/') { render 'index' }
      get('/partial') { partial 'partial' }
      get('/namespace-partial') { partial 'namespace/partial' }
      get('/using-context') { render 'hello' }
      get('/without-layout') { render '_partial', layout: false }
    end
  end

  scope '#default_layout' do
    test 'defaults to application.mote' do
      assert_equal "#{app.to_app.layouts_path}/application.mote", app.to_app.default_layout
    end
  end

  scope '#find_template' do
    test 'returns a template path' do
      assert_equal "#{app.to_app.views_path}/index.mote", app.to_app.find_template('index')
    end
  end

  scope '#layouts_path' do
    test 'returns the path to the layouts directory' do
      assert_equal "#{app.to_app.views_path}/layouts", app.to_app.layouts_path
    end
  end

  scope '#partial' do
    test 'renders a template without a layout' do
      get '/partial'
      assert last_response.ok?
      assert last_response.body !~ /From application.mote/
      assert last_response.body =~ /Hello World!/
    end

    test 'renders a template in namespace without a layout' do
      get '/namespace-partial'
      assert last_response.ok?
      assert last_response.body !~ /From application.erb/
      assert last_response.body =~ /Hello World!/
    end
  end

  scope '#render' do
    test 'renders a template (using a layout)' do
      get '/'
      assert last_response.ok?
      assert last_response.body =~ /From application.mote/
      assert last_response.body =~ /Hello World!/
    end

    test 'renders a template (not using a layout)' do
      get '/without-layout'
      assert last_response.ok?
      assert last_response.body !~ /From application.mote/
      assert last_response.body =~ /Hello World!/
    end

    test 'renders a template using the app as context' do
      get '/using-context'
      assert last_response.ok?
      assert last_response.body =~ /From application.mote/
      assert last_response.body =~ /Hello Hobbit!/
    end
  end

  scope '#views_path' do
    test 'returns the path to the views directory' do
      assert_equal File.expand_path('../fixtures/mote/views', __FILE__), app.to_app.views_path
    end

    test 'defaults to "views"' do
      mock_app do
        include Hobbit::Mote
      end

      assert_equal 'views', app.to_app.views_path
    end
  end
end
