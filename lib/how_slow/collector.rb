module HowSlow
  # Defines a Railtie that loades the metrics collector into your Rails app upon
  # app initialization.
  #
  # This class takes care of logging all the metrics data. It currently supports
  # only a single metric type, the 'action' type (as in a controller action),
  # but there is a placeholder metric type called 'counter`, to later be used
  # to track, for example, usage stats of an app.
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
  # NOTE that the 'view_runtime' and 'db_runtime' attributes may be zero if, for
  # example, the action redirected instead of reading from the database and/or
  # rendering a view to the client. It should also be noted that any database
  # calls triggered by code in the view (such as loading associated records that
  # were not eager loaded in the controller action itself) count as time against
  # the view, NOT the database time. This often throws people off, but the point
  # seems to be to direct you to which step in the response process is involved
  # in eating up what amount of time. Finally the 'other_runtime' attribute is
  # simply whatever time if leftover from 'total_runtime' after you subtract
  # 'view_runtime' and 'db_runtime'.
  #
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
