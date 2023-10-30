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

  def call
    greeting = parameters[:greeting] ? parameters[:greeting] : 'Hello'
    [greeting, parameters[:first_name], parameters[:last_name]].compact.join(' ')
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
    it 'assigns passed arguments to parameters instance variable' do
      bar = BarFunction.new(first_name: 'John', greeting: 'Hi')
      expect(bar.parameters).to eq({ first_name: 'John', greeting: 'Hi' })
      expect(bar.call).to eq('Hi John')
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
                   last_name: { description: 'Your last name', type: :string }
                 },
                 required: ['first_name']
               }
             }
           )
    end
  end
end
