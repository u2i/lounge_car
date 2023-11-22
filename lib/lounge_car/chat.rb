# frozen_string_literal: true

require 'openai'

module LoungeCar
  module Chat
    #     def initialize(function_group = nil)
    #       @function_group = function_group
    #     end
    def send_user_message(message)
      messages.create(role: :user, content: message, data: {})
      send_message
    end

    def send_system_message(message)
      messages.create(role: :system, content: message, data: {})
    end

    def send_function_result(function_name, message)
      messages.create(role: :function, content: message.to_s, data: { name: function_name })
      send_message
    end

    #     def call_function(function_data)
    #       function = @function_group.function(function_data[:name])
    #       arguments = function.instance_method(:call).parameters.map { |_, name| function_data[:arguments][name] }
    #       function.new.call(*arguments)
    #     end

    private

    def send_message
      OpenAI::Client.new.chat(
        parameters: {
          model: 'gpt-3.5-turbo',
          messages: messages.map(&:to_gpt_format),
          stream: handler
        }
      )
    end

    def handle_response(response)
      return StandardError if response['error']

      message = response['choices'][0]['message']

      case response['choices'][0]['finish_reason']
      when 'stop'
        messages.create(role: :assistant, content: message['content'], data: {})
      when 'function_call'
        messages.create(role: :assistant, content: '', data: { function_call: message['function_call'] })
      else
        # length / content_filter
        StandardError
      end
    end

    def handler
      before_message

      proc do |chunk, _bytesize|
        chunk = chunk.dig('choices', 0, 'delta')
        next unless chunk

        on_content_chunk(chunk) if chunk['content']
        on_function_chunk(chunk) if chunk['function_call']
      end
    end

    def before_message
      @message = messages.create(role: :assistant, content: '', data: {})
    end

    def on_content_chunk(chunk)
      @message.update(content: @message.content + chunk['content'].to_s)
      @message.broadcast_update_to('messages', partial: 'lounge_car/messages/message')
    end

    def on_function_chunk(chunk)
      @message.update(data: { function_call: { name: '', arguments: '' } }) unless @message.data[:function_call]

      @message.update(data: { function_call: {
                        name: @message.data[:function_call][:name] + chunk['function_call']['name'].to_s,
                        arguments: @message.data[:function_call][:arguments] + chunk['function_call']['arguments'].to_s
                      } })
    end
  end
end
