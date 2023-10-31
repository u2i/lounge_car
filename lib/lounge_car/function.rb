# frozen_string_literal: true

module LoungeCar
  module Function
    def function_name
      @function_name ||= LoungeCar.to_snake_case(name)
    end

    def set_description(description)
      @description = description
    end

    def add_parameter(name, required, options = {})
      self.required << name if required
      parameters[name] = options
    end

    def to_gpt_format
      {
        name: function_name,
        description: description,
        parameters: {
          type: :object,
          properties: parameters,
          required: required
        }
      }
    end

    private

    def description
      @description ||= ''
    end

    def parameters
      @parameters ||= {}
    end

    def required
      @required ||= []
    end
  end
end
