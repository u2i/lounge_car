# frozen_string_literal: true

require_relative 'lounge_car/version'
require_relative 'lounge_car/function'
require_relative 'lounge_car/function_group'
require_relative 'lounge_car/client'

module LoungeCar
  class Configuration
    attr_accessor :model

    def initialize(model = nil)
      @model = model
    end
  end

  def self.configuration
    @configuration ||= LoungeCar::Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.to_snake_case(string)
    string.gsub(/::/, '_')
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr('-', '_')
          .downcase
  end
end
