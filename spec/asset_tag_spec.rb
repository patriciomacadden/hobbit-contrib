require 'minitest_helper'

describe Hobbit::AssetTag do
  include Hobbit::Contrib::Mock

  def app
    mock_app do
      include Hobbit::AssetTag
    end
  end

  describe '#image_path' do
    describe 'when passing an url' do
      it 'must return the url' do
        url = 'http://example.com/image.png'
        app.to_app.image_path(url).must_equal url
      end
    end

    describe 'when not passing an url' do
      it 'must return a path to an image' do
        app.to_app.image_path('hobbit.png').must_equal '/images/hobbit.png'
      end
    end
  end

  describe '#javascript' do
    describe 'when passing one string' do
      it 'must return one script tag' do
        app.to_app.javascript('application').scan('script src').size.must_equal 1
      end
    end

    describe 'when passing more than one string' do
      it 'must return more than one script tag' do
        app.to_app.javascript('application', 'other_script').scan('script src').size.must_equal 2
      end
    end
  end

  describe '#javascript_path' do
    describe 'when passing an url' do
      it 'must return the url' do
        url = 'http://example.com/app.js'
        app.to_app.javascript_path(url).must_equal url
      end
    end

    describe 'when not passing an url' do
      it 'must return a path to a javascript file' do
        app.to_app.javascript_path('application').must_equal '/javascripts/application.js'
      end
    end
  end

  describe '#stylesheet' do
    describe 'when passing one string' do
      it 'must return one link tag' do
        app.to_app.stylesheet('application').scan('link href').size.must_equal 1
      end
    end

    describe 'when passing more than one string' do
      it 'must return more than one link tag' do
        app.to_app.stylesheet('application', 'other_style').scan('link href').size.must_equal 2
      end
    end
  end

  describe '#stylesheet_path' do
    describe 'when passing an url' do
      it 'must return the url' do
        url = 'http://example.com/app.css'
        app.to_app.stylesheet_path(url).must_equal url
      end
    end

    describe 'when not passing an url' do
      it 'must return a path to a stylesheet file' do
        app.to_app.stylesheet_path('application').must_equal '/stylesheets/application.css'
      end
    end
  end
end