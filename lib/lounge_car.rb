# frozen_string_literal: true

require_relative 'lounge_car/version'
require 'lounge_car/function'

module LoungeCar
  def self.functions
    @functions ||= {}
  end

  def self.function(name)
    functions[name] || raise(LoungeCar::FunctionNameError, "Unknown function class #{name}")
  end

  def self.functions_definitions
    functions.values.map(&:definition)
  end

  def self.call_function(function_name, args)
    function(function_name).new(args).call
  end
end
