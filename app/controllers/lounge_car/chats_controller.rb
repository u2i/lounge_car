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
      @chat.send_system_message LoungeCar.configuration_message if @chat.messages.empty?
      CallGptJob.perform_later(@chat, params[:content])

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('new_message', partial: 'lounge_car/messages/form')
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
