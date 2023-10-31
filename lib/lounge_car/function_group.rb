# frozen_string_literal: true

module LoungeCar
  module FunctionGroup
    def functions
      @functions ||= {}
    end

    def function(function_name)
      @functions[function_name]
    end

    def set_functions(functions = [])
      self.functions.clear
      functions.each { |f| self.functions[f.function_name] = f }
    end

    def add_function(function)
      functions[function.function_name] = function
    end

    def remove_function(function_name)
      functions.delete(function_name)
    end
  end
end
