require 'minitest_helper'

describe Hobbit::EnhancedRender do
  include Rack::Test::Methods

  def app
    TestEnhancedRenderApp.new
  end

  describe '#layout_path' do
    it 'must return a path' do
      path = File.expand_path('../fixtures/test_enhanced_render_app/views/layouts/layout.erb', __FILE__)
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
      path = File.expand_path('../fixtures/test_enhanced_render_app/views/index.erb', __FILE__)
      app.to_app.view_path('index').must_equal path
    end
  end
end