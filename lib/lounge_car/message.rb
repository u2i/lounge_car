# frozen_string_literal: true

module LoungeCar
  module Message
    def to_gpt_format
      message = { role: role, content: content }
      message[:name] = function_call['name'] if role == 'function'
      message[:function_call] = function_call if role == 'assistant' && function_call.any?
      message
    end

    def create_message_on_ui
      if %w[user assistant].include? role
        broadcast_append_to chat, partial: 'lounge_car/messages/message'
      end
    end

    def update_message_on_ui
      if %w[user assistant].include? role
        broadcast_replace_to chat, partial: 'lounge_car/messages/message'
      end
    end
  end
end