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

    def update_chat_cost_on_ui
      broadcast_replace_to self, target: 'chat_cost', partial: 'lounge_car/chats/cost'
    end

    def send_message
      update(input: input + OpenAI.rough_token_count(messages.map(&:to_gpt_format).to_s + LoungeCar.functions.map(&:to_gpt_format).to_s))

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

        choices_chunk = chunk.dig('choices', 0, 'delta')
        next unless choices_chunk

        on_content_chunk(choices_chunk) if choices_chunk['content']
        on_function_chunk(choices_chunk['function_call']) if choices_chunk['function_call']
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
      @message.chat.update(output: @message.chat.output + OpenAI.rough_token_count(@message.content))

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
      function = LoungeCar.function(function_data['name']).new(self)
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
