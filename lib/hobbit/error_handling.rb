module Hobbit
  module ErrorHandling
    module ClassMethods
      def error(exception, &block)
        errors[exception] = block
      end

      def errors
        @errors ||= Hash.new
      end
    end

    def _call(env)
      super
    rescue *self.class.errors.keys => e
      rescued = self.class.errors.keys.detect { |k| e.kind_of?(k) }

      body = instance_eval { self.class.errors[rescued].call(e) }
      response.body = [body]
      response.finish
    end

    def self.included(othermod)
      othermod.extend ClassMethods
    end
  end
end
