require File.join(File.dirname(__FILE__), 'how_slow', 'version')
require File.join(File.dirname(__FILE__), 'how_slow', 'event_subscriptions')

METRICS_LOGGER = Logger.new("#{Rails.root}/log/metrics.log")
