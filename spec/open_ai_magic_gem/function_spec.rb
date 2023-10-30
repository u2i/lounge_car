# frozen_string_literal: true

class FooFunction
  include OpenAiMagicGem::Function

  description 'This is a test Foo function'

  def call
    'Hello from Foo'
  end
end

class BarFunction
  include OpenAiMagicGem::Function

  description 'This is a super useful Bar function that returns a greeting.'
  parameter :first_name, :string, 'Your first name', required: true
  parameter :last_name, :string, 'Your last name'
  parameter :height, :number, 'Your height (in meters)'
  parameter :adult, :boolean, 'Are you adult', required: true

  def call
    greeting = parameters[:greeting] ? parameters[:greeting] : 'Hello'
    [greeting, parameters[:first_name], parameters[:last_name], parameters[:height], parameters[:adult]].compact.join(' ')
  end
end

RSpec.describe OpenAiMagicGem::Function do
  describe '#included' do
    it 'registers classes that include Function module' do
      expect(OpenAiMagicGem.functions.size).to eq(2)
      expect(OpenAiMagicGem.functions['foo_function']).to eq(FooFunction)
      expect(OpenAiMagicGem.functions['bar_function']).to eq(BarFunction)
    end
  end

  describe "#new" do
    it 'throws error when required argument is missing' do
      expect { BarFunction.new(first_name: 'John') }.to raise_error(ArgumentError, "Missing required argument")
    end

    it 'throws error when argument has wrong type' do
      expect { BarFunction.new(first_name: 10, adult: true) }.to raise_error(ArgumentError, "Wrong argument type")
      expect { BarFunction.new(first_name: true, adult: true) }.to raise_error(ArgumentError, "Wrong argument type")
      expect { BarFunction.new(first_name: 'John', adult: 1) }.to raise_error(ArgumentError, "Wrong argument type")
      expect { BarFunction.new(first_name: 'John', adult: 'true') }.to raise_error(ArgumentError, "Wrong argument type")
      expect { BarFunction.new(first_name: 'John', adult: true, height: '3.75') }.to raise_error(ArgumentError, "Wrong argument type")
      expect { BarFunction.new(first_name: 'John', adult: true, height: true) }.to raise_error(ArgumentError, "Wrong argument type")
    end

    it "doesn't check extra arguments" do
      expect(BarFunction.new(first_name: 'John', adult: true, extra_1: 123, greeting: '1@#$%^&*9').call).to eq("1@#$%^&*9 John true")
    end

    it 'assigns passed arguments to parameters instance variable' do
      bar = BarFunction.new(first_name: 'John', last_name: 'Smith', height: 1.85, adult: true)
      expect(bar.parameters).to eq({ first_name: 'John', last_name: 'Smith', height: 1.85, adult: true })
      expect(bar.call).to eq('Hello John Smith 1.85 true')
    end
  end

  describe "#definition" do
    it 'produces a function description compliant with the OpenAI spec' do
      expect(FooFunction.definition).
        to eq(
             {
               name: 'foo_function',
               description: 'This is a test Foo function',
               parameters: {
                 type: :object,
                 properties: {},
                 required: []
               }
             }
           )

      expect(BarFunction.definition).
        to eq(
             {
               name: 'bar_function',
               description: 'This is a super useful Bar function that returns a greeting.',
               parameters: {
                 type: :object,
                 properties: {
                   first_name: { description: 'Your first name', type: :string },
                   last_name: { description: 'Your last name', type: :string },
                   height: { description: 'Your height (in meters)', type: :number },
                   adult: { description: 'Are you adult', type: :boolean }
                 },
                 required: ['first_name', 'adult']
               }
             }
           )
    end
  end
end
