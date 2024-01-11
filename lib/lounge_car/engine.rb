# frozen_string_literal: true

module LoungeCar
  class Engine < ::Rails::Engine
    isolate_namespace LoungeCar

    initializer 'lounge_car.assets' do |app|
      js_path = LoungeCar::Engine.root.join('app/javascript/controllers')
      js_files = Dir.glob(js_path.join('*.js')).map { |f| Pathname.new(f).relative_path_from(js_path).to_s }
      css_path = LoungeCar::Engine.root.join('app/assets/stylesheets')
      css_files = Dir.glob(css_path.join('**/*.css')).map { |f| Pathname.new(f).relative_path_from(css_path).to_s }

      app.config.assets.paths << js_path
      app.importmap.pin_all_from js_path
      app.config.assets.precompile += js_files + css_files
    end
  end
end
