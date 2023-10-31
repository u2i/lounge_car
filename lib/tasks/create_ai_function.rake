# frozen_string_literal: true

require "active_support/all"

namespace :lounge_car do
  desc "Creates a function seeable by ai"
  task :create_ai_function do
    function_name = ARGV[1]
    class_name = function_name.camelize

    file_path = File.expand_path("app/my_folder/#{function_name}.rb", __dir__)

    dir_path = File.dirname(file_path)
    FileUtils.mkdir_p(dir_path) unless Dir.exist?(dir_path)

    content = <<~TEMPLATE
      class #{class_name}
        include LoungeCar::AIFunction

        description "adds two numbers"
        parameter :first_number, :number, "First number to add", required: true
        parameter :second_number, :number, "Second number to add"

        def call
          f_num = parameters[:first_number]
          s_num = parameters[:second_number] || 1
          print "\#{f_num} + \#{s_num} = \#{f_num + s_num}"
        end
      end
    TEMPLATE

    File.write(file_path, content)

    puts "File generated at #{file_path}"
    exit
  end
end
