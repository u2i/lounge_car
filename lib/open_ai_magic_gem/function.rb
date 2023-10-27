# frozen_string_literal: true

require 'active_support/all'

module OpenAiMagicGem
  class FunctionNameError < NameError; end

  module Function
    attr_reader :parameters

    def initialize(args = {})
      # TODO add validation for required
      @parameters = args
    end

    def self.included(base)
      OpenAiMagicGem.functions[base.name.parameterize] = base
      base.extend ClassMethods
    end

    module ClassMethods
      def definition
        @definition ||= {
          name: name.parameterize,
          description: "",
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
  end
end
