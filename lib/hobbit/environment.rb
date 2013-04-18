module Hobbit
  module Environment
    def environment
      self.class.settings[:environment] || ENV['RACK_ENV'].to_sym
    end

    def environment=(environment)
      self.class.settings[:environment] = environment.to_sym
    end

    %w(development production test).each do |environment|
      define_method("#{environment}?") { self.class.settings[:environment] == environment.to_sym }
    end
  end
end
