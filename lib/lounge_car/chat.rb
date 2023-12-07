# frozen_string_literal: true

require 'openai'

module LoungeCar
  module Chat

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
      function_class = LoungeCar.function(function_data['name'])
      function_arguments = JSON.parse(function_data['arguments'])
      arguments = function_class.instance_method(:call).parameters.map { |_, name| function_arguments[name.to_s] }
      function = function_class.new
      function.call(*arguments)
      display_partial(function.partial, function.locals) if function.action == :render
      send_function_result(function_data['name'], function.response)
    end

    def send_function_result(function_name, message)
      messages.create(role: :function, content: message.to_s, function_call: { name: function_name })
      send_message
    end

    def display_partial(partial, locals)
      Turbo::StreamsChannel.broadcast_append_to self, target: 'messages', partial: partial, locals: locals
    end
  end
end
