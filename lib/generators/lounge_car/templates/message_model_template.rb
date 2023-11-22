# frozen_string_literal: true

class Message < ApplicationRecord
  default_scope { order(created_at: :asc) }
  belongs_to :chat
  enum role: { system: 0, assistant: 1, user: 2, function: 3 }
end
