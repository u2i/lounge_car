# frozen_string_literal: true

module LoungeCar
  module Message
    def to_gpt_format
      { role: role, content: content }.merge(function_call.transform_keys(&:to_sym))
    end

    def create_message_on_ui
      if %w[user assistant].include? self.role
        broadcast_append_to 'messages', partial: 'lounge_car/messages/message'
      end
    end

    def update_message_on_ui
      if %w[user assistant].include? self.role
        broadcast_replace_to 'messages', partial: 'lounge_car/messages/message'
      end
    end
  end
end