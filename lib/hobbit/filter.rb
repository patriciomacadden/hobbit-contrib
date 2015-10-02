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
      @response = Hobbit::Response.new([], 200, {}) # pass empty params so that Content-Type header remains unset. otherwise, the main response's Content-Type will be ignored.
      #@response.headers.delete "Content-Type" #another way to undo overriding default content-type
      catch :halt do
        filter :before
        unless @response.status == 302
          # we have to do this because `super` will override @response and @request
          prev_response = @response
          current_response = super
          @response = Hobbit::Response.new current_response[2], current_response[0], current_response[1].merge!(prev_response.headers)
          filter :after unless @halted
        end
        @response.finish
      end
    end

    def halt(response)
      @halted = true
      super
    end

    def self.included(othermod)
      othermod.extend ClassMethods
    end

    private

    def filter(kind)
      find_filters(kind).each do |filter|
        if filter[:compiled_path] =~ request.path_info
          $~.captures.each_with_index do |value, index|
            param = filter[:extra_params][index]
            request.params[param] = value
          end
        end
        instance_eval &filter[:block]
      end
      response.finish if kind == :after
    end

    def find_filters(kind)
      self.class.filters[kind].select { |f| f[:compiled_path] =~ request.path_info || f[:compiled_path] =~ '' }
    end
  end
end
