# frozen_string_literal: true

class Chat < ApplicationRecord
  include LoungeCar::Chat
  after_update_commit :update_chat_cost_on_ui

  has_many :messages, dependent: :destroy

  # def configuration_message
  #   <<~CONFIG
  #     ere you can write any configuration message that should be sent at the beginning of every chat.
  #     For example:
  #     You are a helpful assistant in grocery shop.
  #     Today is #{Date.today}
  #   CONFIG
  # end
end
