# frozen_string_literal: true

class Message < ApplicationRecord
  include LoungeCar::Message
  after_create_commit :create_message_on_ui
  after_update_commit :update_message_on_ui
  default_scope { order(created_at: :asc) }
  belongs_to :chat
  enum role: { system: 0, assistant: 1, user: 2, function: 3 }
end
