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
    rescue *self.errors => e
      base = self.class

      while base.respond_to?(:errors)
        exception = base.errors.keys.detect { |k| e.is_a?(k) }
        next (base = base.superclass) unless exception

        env['hobbit.error'] = e
        response.write instance_eval(&base.errors[exception])
        return response.finish
      end
    end

    def errors
      base = self.class

      errors = []

      while base.respond_to?(:errors)
        errors += base.errors.keys
        next (base = base.superclass)
      end

      errors
    end

    def self.included(othermod)
      othermod.extend ClassMethods
    end
  end
end
