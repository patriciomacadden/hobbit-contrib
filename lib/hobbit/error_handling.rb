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
    rescue Exception => e
      base = self.class

      while base.respond_to?(:errors)
        next base = base.superclass unless exception = base.errors.keys.detect {|k| e.kind_of?(k) }

        env['hobbit.error'] = e
        response.write instance_eval(&base.errors[exception])
        return response.finish
      end

      raise
    end

    def self.included(othermod)
      othermod.extend ClassMethods
    end
  end
end
