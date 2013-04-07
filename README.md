a gem for collecting performance metrics in Rails and reporting them via email

This gem began as a way to easily collect performance metrics for Rails
controller actions without needing to integrate it with an external stats
aggregation server or service.

All metrics are written as serialized hashes, one line per action, to the file
`log/metrics.log`
