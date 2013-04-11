module HowSlow
  class Railtie < Rails::Railtie
    initializer "railtie.configure_rails_initialization" do |app|
      @logger = Logger.new(HowSlow.full_path_to_log_file)

      HowSlow.config[:event_subscriptions].each do |event_name|
        ActiveSupport::Notifications.subscribe event_name do |name, start, finish, id, payload|
          event_metrics = {}
          event_metrics['datetime'] = Time.now.to_s
          event_metrics['type'] = 'action'
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
