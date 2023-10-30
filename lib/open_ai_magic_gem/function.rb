# frozen_string_literal: true

require 'active_support/all'

module OpenAiMagicGem
  class FunctionNameError < NameError; end

  module Function
    attr_reader :parameters

    def initialize(args = {})
      validate_function_arguments args

      @parameters = args
    end

    def self.included(base)
      OpenAiMagicGem.functions[to_snake_case(base.name)] = base
      base.extend ClassMethods
    end

    module ClassMethods
      def definition
        @definition ||= {
          name: Function.to_snake_case(name),
          description: '',
          parameters: {
            type: :object,
            properties: {},
            required: []
          }
        }
      end

      def description(description)
        definition[:description] = description
      end

      def parameter(name, type, description, options = {})
        definition[:parameters][:properties][name] = { type: type, description: description }

        definition[:parameters][:required] << name.to_s if options[:required]
      end
    end

    def self.to_snake_case(string)
      string.gsub(/::/, '_')
            .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
            .gsub(/([a-z\d])([A-Z])/, '\1_\2')
            .tr("-", "_")
            .downcase
    end

    private

    def validate_function_arguments(args)
      parameters = self.class.definition[:parameters]

      unless parameters[:required].all? { |param| args[param.to_sym] }
        raise ArgumentError, "Missing required argument"
      end

      unless args.all? { |name, value| is_given_type(value, parameters[:properties][name.to_sym][:type]) }
        raise ArgumentError, "Wrong argument type"
      end
    end

    def is_given_type(value, type)
      case type
      when :number
        value.is_a? Numeric
      when :string
        value.is_a? String
      when :boolean
        value.is_a?(TrueClass) || value.is_a?(FalseClass)
      else
        true
      end
    end
  end
end
