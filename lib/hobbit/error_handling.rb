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
      body = instance_eval { self.class.errors[e.class].call(e) }
      response.body = [body] if self.class.errors.include? e.class
      response.finish
    end

    def self.included(othermod)
      othermod.extend ClassMethods
    end
  end
end