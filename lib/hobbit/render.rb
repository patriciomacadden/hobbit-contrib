require 'tilt'

module Hobbit
  module Render
    def default_layout
      "#{layouts_path}/application.#{template_engine}"
    end

    def find_template(template)
      "#{views_path}/#{template}.#{template_engine}"
    end

    def layouts_path
      "#{views_path}/layouts"
    end

    def partial(template, locals = {}, options = {}, &block)
      template = find_template "_#{template}"
      _render template, locals, options, &block
    end

    def render(template, locals = {}, options = {}, &block)
      template = find_template template
      layout = default_layout
      if options.include? :layout
        layout = options.delete :layout
      end
      if layout
        _render(layout, locals, options) { _render(template, locals, options) }
      else
        _render template, locals, options
      end
    end

    def template_engine
      'erb'
    end

    def views_path
      'views'
    end

    def clear_cache
      Thread.current[:cache] = nil
    end
    
    private

    def _render(template, locals = {}, options = {}, &block)
      cache.fetch template do
        Tilt.new template, options.merge(outvar: '@_output')
      end.render self, locals, &block
    end

    def cache
      Thread.current[:cache] ||= Tilt::Cache.new
    end
  end
end
