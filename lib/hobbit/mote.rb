require 'mote'

module Hobbit
  module Mote
    include ::Mote::Helpers

    def default_layout
      "#{layouts_path}/application.mote"
    end

    def find_template(template)
      "#{views_path}/#{template}.mote"
    end

    def layouts_path
      "#{views_path}/layouts"
    end

    def partial_path(template)
      parts = template.split('/')
      name = "_#{parts.pop}"
      "#{parts.join('/')}/#{name}"
    end

    def partial(template, params = {}, context = self)
      template = find_template partial_path(template)
      mote template, params, context
    end

    def render(template, params = {}, context = self)
      template = find_template template
      layout = default_layout
      if params.include? :layout
        layout = params.delete :layout
      end
      if layout
        params = params.merge content: mote(template, params, context)
        mote layout, params, context
      else
        mote template, params, context
      end
    end

    def views_path
      'views'
    end
  end
end
