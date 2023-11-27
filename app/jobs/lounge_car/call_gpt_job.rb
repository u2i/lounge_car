# frozen_string_literal: true

module LoungeCar
  class CallGptJob < ActiveJob::Base
    def perform(chat, message)
      chat.send_user_message(message)
    end
  end
end
