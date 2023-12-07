# frozen_string_literal: true

module LoungeCar
  module Function

    attr_reader :action, :response, :partial, :locals

    private

    def render(partial, locals, response = '')
      @action = :render
      @partial = partial
      @locals = locals
    end

    def respond(response)
      @response = response
    end

    module ClassMethods
      def function_name
        @function_name ||= LoungeCar.to_snake_case(name)
      end

      def to_gpt_format
        {
          name: function_name,
          description: @description,
          parameters: {
            type: :object,
            properties: parameters,
            required: required
          }
        }
      end

      private

      def description(description)
        @description = description
      end

      def parameter(name, options = {})
        required << name if options.delete(:required)
        parameters[name] = options
      end

      def parameters
        @parameters ||= {}
      end

      def required
        @required ||= []
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end
  end
end
