module Hobbit
  module Environment
    def self.included(othermod)
      othermod.extend self
    end

    def environment
      ENV['RACK_ENV'].to_sym
    end

    %w(development production test).each do |env|
      define_method("#{env}?") { environment == env.to_sym }
    end
  end
end
