# frozen_string_literal: true

class TestFunction; end

RSpec.describe LoungeCar do
  let(:functions) do
    { 'test_function' => TestFunction }
  end

  before do
    described_class.instance_variable_set(:@functions, functions)
  end

  it "has a version number" do
    expect(LoungeCar::VERSION).not_to be nil
  end

  describe '#functions' do
    it 'returns functions hash' do
      expect(described_class.functions).to eq(functions)
    end
  end

  describe '#function' do
    context 'when function exists' do
      it 'returns the function class' do
        expect(described_class.function('test_function')).to eq(TestFunction)
      end
    end

    context 'when function does not exist' do
      it 'raises exception' do
        expect { described_class.function('unknown') }.
          to raise_error(LoungeCar::FunctionNameError, "Unknown function class unknown")
      end
    end
  end

  describe '#functions_definitions' do
    before do
      expect(TestFunction).to receive(:definition).
        and_return({ name: 'test_function', description: 'This is a test function' })
    end

    it 'returns an array of function definitions' do
      expect(described_class.functions_definitions).
        to eq([{ name: 'test_function', description: 'This is a test function' }])
    end
  end

  describe '#call_function' do
    let(:function_instance) { double('TestFunction')  }

    it 'creates an instance of the function class and invokes .call method' do
      expect(TestFunction).to receive(:new).with({ foo: 1, bar: 2 }) { function_instance }
      expect(function_instance).to receive(:call)
      described_class.call_function('test_function', foo: 1, bar: 2)
    end
  end
end
