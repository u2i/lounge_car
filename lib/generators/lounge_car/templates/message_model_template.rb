# frozen_string_literal: true

class Message < ApplicationRecord
  after_create_commit -> { broadcast_append_to 'messages', partial: 'lounge_car/messages/message' }
  default_scope { order(created_at: :asc) }
  belongs_to :chat
  enum role: { system: 0, assistant: 1, user: 2, function: 3 }

  def to_gpt_format
    { role: role, content: content }.merge(data)
  end
end
