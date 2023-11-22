# frozen_string_literal: true

class Chat < ApplicationRecord
  include LoungeCar::Chat

  has_many :messages, dependent: :destroy
end
