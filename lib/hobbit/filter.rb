module Hobbit
  module Filter
    module ClassMethods
      %w(after before).each do |kind|
        define_method(kind) { |path = '', &block| filters[kind.to_sym] << compile_filter(path, &block) }
      end

      def filters
        @filters ||= Hash.new { |hash, key| hash[key] = [] }
      end

      private

      def compile_filter(path, &block)
        filter = { block: block, compiled_path: nil, extra_params: [], path: path }

        compiled_path = path.gsub(/:\w+/) do |match|
          filter[:extra_params] << match.gsub(':', '').to_sym
          '([^/?#]+)'
        end
        filter[:compiled_path] = /^#{compiled_path}$/

        filter
      end
    end

    def _call(env)
      env['PATH_INFO'] = '/' if env['PATH_INFO'].empty?
      @env = env
      @request = Rack::Request.new(@env)
      @response = Hobbit::Response.new
      catch :halt do
        filter :before
        unless @response.status == 302
          super
          filter :after unless @halted
        end
      end
      @response.finish
    end

    def halt(*res)
      @halted = true
      super
    end

    def self.included(othermod)
      othermod.extend ClassMethods
    end

    private

    def filter(kind)
      filter = find_filter(kind)
      if filter
        instance_eval(&filter[:block])
      end
    end

    def find_filter(kind)
      filter = self.class.filters[kind].detect do |f|
        f[:compiled_path] =~ request.path_info || f[:compiled_path] =~ ''
      end

      if filter
        $~.captures.each_with_index do |value, index|
          param = filter[:extra_params][index]
          request.params[param] = value
        end
      end

      filter
    end
  end
end
