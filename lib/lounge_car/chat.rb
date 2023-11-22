# frozen_string_literal: true

require 'openai'

module LoungeCar
  module Chat
    #     attr_reader :messages
    #
    #     def initialize(function_group = nil)
    #       @messages = []
    #       @client = OpenAI::Client.new
    #       @function_group = function_group
    #     end
    #
    #     def send_user_message(message)
    #       @messages << { role: 'user', content: message }
    #       send_message
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
    end

    #
    #     def send_system_message(message)
    #       @messages << { role: 'system', content: message }
    #     end
    #
    #     def send_function_result(function_name, message)
    #       @messages << { role: 'function', name: function_name, content: message.to_s }
    #       send_message
    #     end
    #
    #     def call_function(function_data)
    #       function = @function_group.function(function_data[:name])
    #       arguments = function.instance_method(:call).parameters.map { |_, name| function_data[:arguments][name] }
    #       function.new.call(*arguments)
    #     end
    #
    #     private
    #
    #     def send_message
    #       handle_response(
    #         @client.chat(
    #           parameters: {
    #             model: LoungeCar.configuration.model,
    #             messages: @messages,
    #             functions: functions
    #           }
    #         )
    #       )
    #     end
    #
    def send_message
      # handle_response(
      #   OpenAI::Client.new.chat(
      #     parameters: {
      #       model: 'gpt-3.5-turbo',
      #       messages: messages.map(&:to_gpt_format),
      #       stream: handler
      #     }
      #   )
      # )
      OpenAI::Client.new.chat(
        parameters: {
          model: 'gpt-3.5-turbo',
          messages: messages.map(&:to_gpt_format),
          stream: handler
        }
      )
    end

    def handle_response(response)
      p 'response: ----------------------------'
      p response
      return

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

    #
    #     def handle_response(response)
    #       return StandardError if response['error']
    #
    #       message = response['choices'][0]['message']
    #
    #       case response['choices'][0]['finish_reason']
    #       when 'stop'
    #         @messages << { role: 'assistant', content: message['content'] }
    #         { type: :message, content: message['content'] }
    #       when 'function_call'
    #         @messages << { role: 'assistant', content: nil, function_call: message['function_call'] }
    #         {
    #           type: :function_call,
    #           name: message['function_call']['name'],
    #           arguments: JSON.parse(message['function_call']['arguments'], symbolize_names: true)
    #         }
    #       else # length / content_filter
    #         StandardError
    #       end
    #     end
    #
    #     def functions
    #       return unless @function_group
    #       @function_group.functions.values.map(&:to_gpt_format)
    #     end

    private

    def handler
      message = messages.create(role: :assistant, content: '', data: {})
      # message.broadcast_append_later_to(
      #   "#{dom_id(chat)}_messages",
      #   partial: self.to_partial_path,
      #   locals: { message: self, scroll_to: true },
      #   target: "#{dom_id(chat)}_messages"
      # )
      proc do |chunk, _bytesize|
        # if chunk.dig('choices', 0, 'finish_reason') == 'stop'
        #   redirect_to message
        # end

        chunk = chunk.dig('choices', 0, 'delta')
        next unless chunk

        if chunk['content']
          message.update(content: message.content + chunk['content'].to_s)
        end

        if chunk['function_call']
          message.update(data: { function_call: { name: '', arguments: '' } }) unless message.data[:function_call]

          message.update(data: { function_call: {
            name: message.data[:function_call][:name] + chunk['function_call']['name'].to_s,
            arguments: message.data[:function_call][:arguments] + chunk['function_call']['arguments'].to_s
          } })
        end
      end
    end
  end
end
