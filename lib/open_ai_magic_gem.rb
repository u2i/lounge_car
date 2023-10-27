# frozen_string_literal: true

require_relative "open_ai_magic_gem/version"
require "open_ai_magic_gem/function"

module OpenAiMagicGem

  def self.functions
    @functions ||= {}
  end

  def self.function(name)
    function_class = functions[name]
    raise OpenAiMagicGem::FunctionNameError.new("Unknown function class #{name}") unless function_class

    function_class
  end

  def self.functions_definitions
    functions.values.map(&:definition)
  end

  def self.call_function(function_name, args)
    function(function_name).new(args).call
  end
end
