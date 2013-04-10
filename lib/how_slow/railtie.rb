module HowSlow
  # Configuration defaults
  @config = {
              :log_file => "metrics.log",
              :event_subscriptions => [/process_action.action_controller/],
              :logger_filename => nil
            }
  @valid_config_keys = @config.keys
  @logger = nil

  def self.configure(opts = {})
    opts.each {|k,v| @config[k.to_sym] = v if @valid_config_keys.include? k.to_sym}
  end

  def self.config
    @config
  end

  class Railtie < Rails::Railtie
    initializer "railtie.configure_rails_initialization" do |app|
      config[:logger_filename] = "#{Rails.root}/log/#{HowSlow.config[:log_file]}"
      @logger = Logger.new(config[:logger_filename])

      HowSlow.config[:event_subscriptions].each do |event_name|
        ActiveSupport::Notifications.subscribe event_name do |name, start, finish, id, payload|
          event_metrics = {}
          event_metrics['datetime'] = Time.now.to_s
          event_metrics['event_name'] = 'all_requests'
          event_metrics['status'] = payload[:status]
          
          total_runtime = event_metrics['total_runtime'] = (finish-start)*1000
          db_runtime = event_metrics['db_runtime'] = payload[:db_runtime] || 0.0 
          view_runtime = event_metrics['view_runtime'] = payload[:view_runtime] || 0.0 
          
          event_metrics['other_runtime'] = (total_runtime-db_runtime-view_runtime)
                
          event_metrics['params'] = payload[:params]
          @logger.info(event_metrics.to_json)
        end
      end
    end
  end
end
