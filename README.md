# LoungeCar

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add lounge_car

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install lounge_car

## Usage

`require 'lounge_car'`

```
class FooFunction
    include LoungeCar::Function

    description "Function that do foo things"
    parameter :start_date, :string, "Future start date of interest formatted as YYYY-MM-DD", required: true
    parameter :end_date, :string, "Future end date of interest formatted as YYYY-MM-DD"

    def call
       print "Hello. You've requested #{parameters[:start_date]} and #{parameters[:end_date]}"
    end
end
```

```
class BarFunction
    include LoungeCar::Function

    description "Function that do bar thing"
end
```

```
LoungeCar.functions_definitions
LoungeCar.function("bar_function").definition
BarFunction.definition
LoungeCar.call_function("foo_function", start_date: Date.today.to_s, end_date: (Date.today + 2.days).to_s)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/lounge_car.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
