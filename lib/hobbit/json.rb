require 'multi_json'

module Hobbit
  module JSON
    def json(object)
      response.headers['Content-Type'] = resolve_content_type
      resolve_encoder_action(object, resolve_encoder)
    end

    private

    def resolve_content_type
      'application/json'
    end

    def resolve_encoder_action(object, encoder)
      [:encode, :generate].each do |method|
        return encoder.send(method, object) if encoder.respond_to? method
      end

      if encoder.is_a? Symbol
        object.__send__(encoder)
      else
        fail "#{encoder} does not respond to #generate nor #encode"
      end
    end

    def resolve_encoder
      ::MultiJson
    end
  end
end
