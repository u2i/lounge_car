# frozen_string_literal: true

module LoungeCar
  class ChatsController < ApplicationController
    before_action :set_chat, except: [:create, :new]

    def new; end

    def show; end

    def create
      @chat = ::Chat.new
      @chat.send("#{LoungeCar.warden}=", LoungeCar.current_warden(self)) if LoungeCar.warden
      @chat.save!

      redirect_to @chat
    end

    def send_message
#       message1 = <<TEXT
# You are a helpful assistant in HR organization.
# Try to respond shortly, do not write obvious facts and do not dream up information.
# If you cannot help, offer creating a draft message to support department.
# You are talking with #{@chat.user.first_name} #{@chat.user.last_name}, they have #{@chat.user.role} role.
# TEXT
#
#       message2 = <<TEXT
# When creating e-mail on specific subject, try to obtain and include important information.
# [{"subject": "Incorrect PTO balance", "required_information": ["Which PTO type/bank?", "What is the current balance?", "What should the correct balance be?"]},
# {"subject": "Missed hours from previous pay period", "required_information": ["Which pay period is in question?", "How many hours are missing?", "On what days did these hours occur?"]}]
# When writing about any other subject, ask employee about all information they claim useful.
# TEXT
#       if @chat.messages.empty?
#         @chat.send_system_message message1
#         @chat.send_system_message message2
#       end

      if @chat.messages.empty?
        @chat.send_system_message @chat.configuration_message
        LoungeCar.functions.each do |func_class|
          func = func_class.new(@chat)
          system_message = func.respond_to?(:system_message) ? func.system_message : nil
          if system_message
            @chat.send_system_message("Instruction for #{func_class.function_name}: #{system_message}")
          end
        end
      end

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
