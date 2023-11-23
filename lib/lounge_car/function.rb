# frozen_string_literal: true

module LoungeCar
  module Function
    def function_name
      @function_name ||= LoungeCar.to_snake_case(name)
    end

    def description(description)
      @description = description
    end

    def parameter(name, options = {})
      required << name if options.delete(:required)
      parameters[name] = options
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

    def parameters
      @parameters ||= {}
    end

    def required
      @required ||= []
    end
  end
end
