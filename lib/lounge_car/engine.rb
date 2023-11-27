module LoungeCar
  class Engine < ::Rails::Engine
    isolate_namespace LoungeCar

    initializer 'lounge_car.assets.precompile' do |app|
      app.config.assets.precompile += %w[lounge_car/application.css]
    end
  end
end
