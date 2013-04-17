require 'hobbit/render'

module Hobbit
  module EnhancedRender
    include Hobbit::Render

    def layout_path(template)
      "views/layouts/#{template}.erb"
    end

    def partial(template, locals = {}, options = {}, &block)
      render "_#{template}", locals, options, &block
    end

    def render(template, locals = {}, options = {}, &block)
      template = view_path(template)
      layout = options.delete(:layout)
      if layout.nil?
        super
      else
        super(layout_path layout) { super }
      end
    end

    def view_path(template)
      "views/#{template}.erb"
    end
  end
end
