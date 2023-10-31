# frozen_string_literal: true

require_relative 'lib/lounge_car/version'

Gem::Specification.new do |spec|
  spec.name = 'lounge_car'
  spec.version = LoungeCar::VERSION
  spec.authors = ['Bartosz Buczek', 'Tomasz Handzlik']
  spec.email = %w[bartosz.buczek@u2i.com tomek.handzlik@u2i.com]

  spec.summary = 'OpenAi integration for Ruby on Rails'
  spec.description = 'This gem allows to use OpenAi in your application'
  spec.homepage = 'https://github.com/u2i/lounge_car'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.6'
  spec.add_development_dependency 'rubocop', '~> 1.21'
end