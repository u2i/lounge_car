# frozen_string_literal: true

module LoungeCar
  class Client
    attr_reader :messages

    def initialize(function_group = nil)
      @messages = []
      @client = OpenAI::Client.new
      @function_group = function_group
    end

    def send_user_message(message)
      @messages << { role: 'user', content: message }
      send_message
    end

    def send_system_message(message)
      @messages << { role: 'system', content: message }
    end

    def send_function_result(function_name, message)
      @messages << { role: 'function', name: function_name, content: message.to_s }
      send_message
    end

    def call_function(function_data)
      function = @function_group.function(function_data[:name])
      arguments = function.instance_method(:call).parameters.map { |_, name| function_data[:arguments][name] }
      function.new.call(*arguments)
    end

    private

    def send_message
      handle_response(
        @client.chat(
          parameters: {
            model: LoungeCar.configuration.model,
            messages: @messages,
            functions: functions
          }
        )
      )
    end

    def handle_response(response)
      return StandardError if response['error']

      message = response['choices'][0]['message']

      case response['choices'][0]['finish_reason']
      when 'stop'
        @messages << { role: 'assistant', content: message['content'] }
        { type: :message, content: message['content'] }
      when 'function_call'
        @messages << { role: 'assistant', content: nil, function_call: message['function_call'] }
        {
          type: :function_call,
          name: message['function_call']['name'],
          arguments: JSON.parse(message['function_call']['arguments'], symbolize_names: true)
        }
      else # length / content_filter
        StandardError
      end
    end

    def functions
      return unless @function_group
      @function_group.functions.values.map(&:to_gpt_format)
    end
  end
end