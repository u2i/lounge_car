# frozen_string_literal: true

require 'lounge_car/version'
require 'lounge_car/engine'
require 'lounge_car/function'
require 'lounge_car/chat'

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
