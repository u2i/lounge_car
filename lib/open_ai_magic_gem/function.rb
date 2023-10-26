# frozen_string_literal: true

module OpenAiMagicGem
  module Function
    @importers = []

    attr_reader :definition

    def self.extended(base)
      @importers << base
      base.init_definition
    end

    def self.importers
      @importers
    end

    def init_definition
      @definition = {
        name: name,
        description: "",
        parameters: {
          type: :object,
          properties: {},
          required: []
        }
      }
    end

    def set_description(description)
      @definition[:description] = description
    end

    def add_property(name, type, description)
      @definition[:parameters][:properties][name] = { type: type, description: description }
    end

    def set_required(required)
      @definition[:parameters][:required] = required.map(&:to_s)
    end
  end
end

# usage
#
# class FirstClass
#   extend OpenAiMagicGem::Function
#   set_description "class that do first thing"
#   add_property(:start_date, :string, "Future start date of interest formatted as YYYY-MM-DD")
#   add_property(:end_date, :string, "Future end date of interest formatted as YYYY-MM-DD")
#   set_required([:start_date, :end_date])
# end
#
# class LastClass
#   extend OpenAiMagicGem::Function
#   set_description "class that do second thing"
# end
#
# p MyModule.importers
# p MyModule.importers.first.definition
# p MyModule.importers.last.definition
