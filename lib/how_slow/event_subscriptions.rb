ActiveSupport::Notifications.subscribe /process_action.action_controller/ do |name, start, finish, id, payload|
  @@metrics_logger ||= Logger.new("#{Rails.root}/log/metrics.log")

  event_metrics = {}
  event_metrics['datetime'] = Time.now.to_s
  event_metrics['event_name'] = 'all_requests'
  event_metrics['status'] = payload[:status]
  
  total_runtime = event_metrics['total_runtime'] = (finish-start)*1000
  db_runtime = event_metrics['db_runtime'] = payload[:db_runtime] || 0.0 
  view_runtime = event_metrics['view_runtime'] = payload[:view_runtime] || 0.0 
  
  event_metrics['other_runtime'] = (total_runtime-db_runtime-view_runtime)
        
  event_metrics['params'] = payload[:params]
  @@metrics_logger.info(event_metrics.to_json)
end

