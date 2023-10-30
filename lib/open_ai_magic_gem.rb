# frozen_string_literal: true

require_relative "open_ai_magic_gem/version"
require "open_ai_magic_gem/function"

module OpenAiMagicGem
  def self.functions
    @functions ||= {}
  end

  def self.function(name)
    functions[name] || raise(OpenAiMagicGem::FunctionNameError, "Unknown function class #{name}")
  end

  def self.functions_definitions
    functions.values.map(&:definition)
  end

  def self.call_function(function_name, args)
    function(function_name).new(args).call
  end
end
