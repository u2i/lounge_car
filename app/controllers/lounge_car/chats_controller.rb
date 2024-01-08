# frozen_string_literal: true

module LoungeCar
  class ChatsController < ApplicationController
    before_action :set_chat, except: [:index, :create]

    def index
      @chats = ::Chat.all.order(:id)
    end

    def show;
      @chats = ::Chat.all.order(:id)
    end

    def create
      @chat = ::Chat.new
      @chat.send("#{LoungeCar.warden}=", LoungeCar.current_warden(self)) if LoungeCar.warden
      @chat.save!

      redirect_to @chat
    end

    def send_message
      send_configuration_messages unless @chat.messages.any?
      CallGptJob.perform_later(@chat, params[:content])

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('new_message', partial: 'lounge_car/messages/form')
        end
        format.html { redirect_to @chat }
      end
    end

    private

    def send_configuration_messages
      @chat.send_system_message @chat.configuration_message
      LoungeCar.functions.each do |func_class|
        func = func_class.new(@chat)
        if func.respond_to?(:system_message)
          @chat.send_system_message("Instruction for #{func_class.function_name} function: #{func.system_message}")
        end
      end
    end

    def set_chat
      @chat = ::Chat.find(params[:id])
    end
  end
end
