# frozen_string_literal: true

require 'openai'

module LoungeCar
  module Chat
    FUNCTION_RESPONSE_LENGTH_LIMIT = 200

    def send_user_message(message)
      messages.create(role: :user, content: message, function_call: {})
      send_message
    end

    def send_system_message(message)
      messages.create(role: :system, content: message, function_call: {})
    end

    private

    def send_message
      OpenAI::Client.new.chat(
        parameters: {
          model: LoungeCar.model,
          messages: messages.map(&:to_gpt_format),
          functions: LoungeCar.functions.map(&:to_gpt_format),
          stream: handler
        }
      )
    end

    def handler
      before_message

      proc do |chunk, _bytesize|
        raise StandardError if chunk['error']

        finish_reason = chunk.dig('choices', 0, 'finish_reason')
        after_message(finish_reason) unless finish_reason.nil?

        chunk = chunk.dig('choices', 0, 'delta')
        next unless chunk

        on_content_chunk(chunk) if chunk['content']
        on_function_chunk(chunk['function_call']) if chunk['function_call']
      end
    end

    def before_message
      @message = messages.create(role: :assistant, content: '', function_call: {})
    end

    def on_content_chunk(chunk)
      @message.update(content: @message.content + chunk['content'].to_s)
    end

    def on_function_chunk(chunk)
      function_call = @message.function_call == {} ? { 'name' => '', 'arguments' => '' } : @message.function_call
      function_call['name'] += chunk['name'].to_s
      function_call['arguments'] += chunk['arguments'].to_s

      @message.update(function_call: function_call)
    end

    def after_message(finish_reason)
      case finish_reason
      when 'function_call'
        call_function(@message.function_call)
      when 'stop'
        # nothing to do
      else
        # length / content_filter
        raise StandardError
      end
    end

    def call_function(function_data)
      function = LoungeCar.function(function_data['name']).new
      function.call(*function_arguments(function_data))
      render_function(function) if function.action == :render
      send_function_message(function)
    end

    def function_arguments(data)
      function = LoungeCar.function(data['name'])
      arguments = JSON.parse(data['arguments'])
      function.instance_method(:call).parameters.map { |_, name| arguments[name.to_s] }
    end

    def render_function(function)
      broadcast_append target: 'messages', partial: function.partial, locals: function.locals
    end

    def send_function_message(function)
      message = messages.create(
        role: :function,
        content: function.response.to_s,
        function_call: { name: function.class.function_name, renderable: function.action == :render }
      )
      send_message
      if message.content.length > FUNCTION_RESPONSE_LENGTH_LIMIT
        message.update(
          content: 'Function result is lenghty. Call the function again if you still need these information.'
        )
      end
    end
  end
end
