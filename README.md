# LoungeCar

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add lounge_car

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install lounge_car

## Usage
require gems
```
require 'openai'
require 'lounge_car'
```

initialize them
```
OpenAI.configure do |config|
https://github.com/alexrudall/ruby-openai/
end

LoungeCar.configure do |config|
  config.model = 'choose your model, eg.: gpt-3.5-turbo-0613'
end
```
define functions
```
class GetWeather
  extend LoungeCar::Function

  set_description 'get weather in given location at given time (default time is today)'
  add_parameter :location, true, type: :string, description: 'The city and state, e.g. San Francisco, CA'
  add_parameter :date, false, type: :string, description: 'Future date of interest formatted as YYYY-MM-DD'
  add_parameter :unit, true, type: :string, enum: %w[celsius fahrenheit]

  def call(location, unit, date = nil)
    date ||= Date.today
    "20 degrees #{unit} and rain in #{location} on #{date}."
  end
end

class GetTraffic
  extend LoungeCar::Function

  set_description 'get information about traffic jams in given location, at given time (default date_time in now)'
  add_parameter :location, true, type: :string, description: 'The city and state, e.g. San Francisco, CA'
  add_parameter :date_time, false, type: :string, description: 'date and time in format YYYY-MM-DD, HH:MM:SS'

  def call(location, date_time = nil)
    date_time ||= DateTime.now
    "#{location} at #{date_time} will be stacked in jams."
  end
end
```
You can group functions
```
class DefaultAiFunctions
  extend LoungeCar::FunctionGroup

  set_functions([GetTraffic, GetWeather])
end
```
Talk with AI
```
client = LoungeCar::Client.new(DefaultAiFunctions)
client.send_system_message('You are a helpful assistant')
response = client.send_user_message('What is the weather like in San Francisco?')
if response[:type] == :function_call
  p client.send_function_result(response[:name], client.call_function(response))
else
  p response
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/lounge_car.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
