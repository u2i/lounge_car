# frozen_string_literal: true

require 'lounge_car/version'
require 'lounge_car/engine'
require 'lounge_car/function'
require 'lounge_car/message'
require 'lounge_car/chat'

module LoungeCar
  class Configuration
    attr_accessor :model, :functions, :configuration_message

    def initialize(model = nil, functions = [], configuration_message = '')
      @model = model
      @functions = functions
      @configuration_message = configuration_message
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

  def self.functions
    configuration.functions.map(&:constantize)
  end

  def self.function(function_name)
    functions.find { |f| f.function_name == function_name }
  end

  def self.model
    configuration.model
  end

  def self.configuration_message
    configuration.configuration_message
  end
end
