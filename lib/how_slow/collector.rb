require 'rails'

module HowSlow
  # Defines a Railtie that loads the metrics collector into your Rails app upon
  # app initialization.
  #
  # By default every controller action in your entire app is captured and timed.
  # Every metric recorded logs the following info into the metrics log file as
  # a JSON string.
  #
  #   {
  #     'datetime': [the time the action was triggered],
  #     'type': 'action',
  #     'event_name': 'all_requests',
  #     'status': [the HTTP status code returned],
  #     'total_runtime': [total time to process the controller action],
  #     'db_runtime':    [time spent in DB operatations],
  #     'view_runtime':  [time spent rendering the view],
  #     'other_runtime': [total_runtime - db_runtime - view_runtime],
  #     'params': [the params hash sent to the controller action]
  #   }
  #
  # An actual metric might look like the following:
  #
  #   {
  #     'datetime':'2013-01-05 23:01:65 UTC',
  #     'type':'action',
  #     'event_name':'all_requests',
  #     'status':200,
  #     'total_runtime':2.420   # all times are in milliseconds
  #     'db_runtime':1.001,
  #     'view_runtime':0.972,
  #     'other_runtime':0.477,
  #     'params':'{:controller' => 'home', :action => 'index'}
  #   }
  #
  # All timing attributes are in miiliseconds, and stored as a floating point
  # value.
  #
  # The 'other_runtime' attribute is simply whatever time if leftover from
  # 'total_runtime' after you subtract 'view_runtime' and 'db_runtime'.
  #
  class Collector < Rails::Railtie
    @logger

    initializer "railtie.configure_rails_initialization" do |app|
      case HowSlow.config[:storage]
      when :log_file setup_log_storage_and_reporting
    end

    def self.setup_log_storage_and_reporting
      @logger = Logger.new(HowSlow.full_path_to_log_file)

      HowSlow.config[:event_subscriptions].each do |event_name|
        ActiveSupport::Notifications.subscribe event_name do |name, start, finish, id, payload|
          total_runtime = (finish-start)*1000
          db_runtime = payload[:db_runtime] || 0.0 
          view_runtime = payload[:view_runtime] || 0.0 
 
          # TODO add initialization of Ruby object
          # Then serialize it using as_json.to_json
          # then write it to the file
          metric = HowSlow::Metrics::Action.new(
            :datetime => Time.now,
            :event_name => event_name,
            :status => payload[:status],
            :total_runtime => total_runtime,
            :db_runtime => db_runtime,
            :view_runtime => view_runtime,
            :other_runtime => total_runtime-db_runtime-view_runtime,
            :params => payload[:params]
          )
          
          @logger.info(metric.as_json.to_json
        end
      end

    end # setup_log_storage_and_reporting
  end # Collector class
end # HowSlow module
