class TestEnhancedRenderApp < Hobbit::Base
  include Hobbit::EnhancedRender

  # we do this because it the layout path is relative to file being run
  def layout_path(template)
    File.expand_path("../#{super}", __FILE__)
  end

  # we do this because it the view path is relative to file being run
  def view_path(template)
    File.expand_path("../#{super}", __FILE__)
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