module Hobbit
  module Filter
    module ClassMethods
      %w(after before).each do |kind|
        define_method(kind) { |path = '', &block| filters[kind.to_sym] << compile_filter!(path, &block) }
      end

      def filters
        @filters ||= Hash.new { |hash, key| hash[key] = [] }
      end

      private

      def compile_filter!(path, &block)
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
      @env = env
      @request = self.class.settings[:request_class].new(@env)
      @response = self.class.settings[:response_class].new
      filter!(:before)
      super
      filter!(:after)
      @response.finish
    end

    def self.included(othermod)
      othermod.extend ClassMethods
    end

    private

    def filter!(kind)
      filter = self.class.filters[kind].detect { |f| f[:compiled_path] =~ request.path_info || f[:path] =~ // }
      if filter
        $~.captures.each_with_index do |value, index|
          param = filter[:extra_params][index]
          request.params[param] = value
        end
        instance_eval(&filter[:block])
      end
    end
  end
end