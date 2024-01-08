# frozen_string_literal: true

LoungeCar::Engine.routes.draw do
  resources :chats, only: %i[index show create] do
    post 'send_message', on: :member
  end
end
