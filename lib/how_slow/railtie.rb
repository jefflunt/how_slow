module HowSlow
  class Railtie < Rails::Railtie
    initializer "railtie.configure_rails_initialization" do |app|
      METRICS_LOGGER = Logger.new("#{app.root}/log/metrics.log")
    end
  end
end
