# frozen_string_literal: true

module LoungeCar
  class ChatsController < ApplicationController
    before_action :set_chat, except: [:create]

    def show; end

    def create
      @chat = ::Chat.create
      redirect_to @chat
    end

    def send_message
      @chat.send_user_message(params[:content])

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append('messages', partial: 'lounge_car/messages/message', locals: { message: @chat.messages.last })
        end
        format.html { redirect_to @chat }
      end
    end

    private

    def set_chat
      @chat = ::Chat.find(params[:id])
    end
  end
end
