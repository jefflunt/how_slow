# how_slow

Allows you to easily collect Rails app performance metrics to a log file.

## Back story

This gem began as a way to easily collect performance metrics for Rails
controller actions without needing to integrate it with an external stats
aggregation server or service. I started writing it because I work on Rails apps
in an environment where it's not always easy or feasible to ship logs or other
metrics data off to places to NewRelic, for reasons such as possible data
security leakage. I have also been looking for a performance metrics solution
that doesn't require a 3rd party service, or the installation of something like
[statsd](https://github.com/etsy/statsd/) just to get up and running.

In other words, I needed a simple way to capture performnace metrics for simple
Rails apps, without a lot of trouble, and without potentially exposing log data
to a 3rd party.

## Usage

Simply add `how_slow` to your `Gemfile`

    gem 'how_slow'

All metrics are written as serialized JSON, one line per action, to the file
`log/metrics.log`

There are currently only two config options:

* `:log_file` - changes the name of the file where the metrics are written
* `:event_subscriptions` - an array of regular expressions for matching which
  events you want to subscribe to via `ActiveSupport::Notifications`. The
  default is to simply subscribe to *all* `ActionController` events.
