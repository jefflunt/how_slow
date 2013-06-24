# how_slow

Collect Rails app performance and usage metrics without relying on 3rd party
services or setting up a separate logging server.

#### travis-ci build status:

[![Build Status](https://travis-ci.org/normalocity/how_slow.png?branch=master)](https://travis-ci.org/normalocity/how_slow)

Want to run the tests yourself?

    bundle install
    bundle exec rake test

`how_slow` is built against several ruby implementations. See `.travis.yml`

## Reasons to use `how_slow`

* You're in an environment where the risk of sensitive data accidentally being
  sent to a 3rd party service is unacceptable. So, you can't use [NewRelic][4].
* You want a solution that doesn't rely on a 3rd party at all, simplifying your
  application dependencies.
* You don't need all the flashy charts and graphs of [NewRelic][4] and you're
  note afraid to tweak some environment files to get just the metrics you want.
* The idea of setting up and maintaingin a [statsd][2] server along with a
  graphing/charting software stack to display it just sounds like a waste of
  time.
* 99% of your needs could be fulfilled by a simple, weekly email that lists your
  slowest controller actions and your most used features.

## Install

    # Gemfile
    gem 'how_slow'

## Storage

### Performance stats

`how_slow` will automatically capture performance metrics for every
single controller action in your Rails app by default in a file:

    %Rails.root%/log/metrics.log

You can [change](#configuration) the name of this file if you wish.

You can [change](#configuration) the list of controller actions that are captured.

### Usage stats

Want to count logins in order to figure out how many monthly active users you have?

In your controller code:

    # Use the `count` method to count an arbitrarily named metric
    HowSlow::Collector::count('user_login')

Specify an optional number parameter to count up or down by any whole number:

    # e.g. customer ordered three items:
    HowSlow::Collector::count('items_ordered', 3)

    # e.g. customer returned two items:
    HowSlow::Collector::count('items_ordered', -2)

## Retrieval

### Via email:

    # rake task
    rake how_slow:metrics_email

    # in code
    HowSlow::Mailer.metrics_email(options)

* See the `lib/how_slow/mailer.rb` class for which options are availble.
* Configure default email options in your environemnt file. See
  `lib/how_slow/setup.rb` for a list of defaults.

Inside a Rails app (see `lib/how_slow/reporter.rb` for more examples) and
documentation on default options:

    reporter = HowSlow::Reporter.new
    reporter.slowest_actions_by(:total_runtime)
    => [HowSlow::Metrics::Action<# >, ...]   # sorted by #total_runtime
    
    reporter.slowest_actions_by(:db_runtime, 50, 1.month.ago)
    => [HowSlow::Metrics::Action<# >, ...]   # limited to metrics in the last month
    
    reporter.sum_counters_by('user_login')
    => 235

## Configuration

Four configuration options are supported:

* `:event_subscriptions` - an array of regex patters used to match actions. For
  more on how that works, see the documentation on
  [ActiveSupport::Notifications Subscribers][3]. `how_slow` will default to
  tracking **all** controller actions automatically if you don't explicitly set
  this option.
* `:logger_filename` - the name of the file to write the metrics logs. The
  default is `metrics.log`, which winds up placing the file under
  `"#{Rails.root}/log/metrics.log"`
* `:storage` - the storage method. Right now the default (and only option) is
  `:log_file`, however support for collecting metrics into your database via an
  `:active_record` option [is planned][10]. That means being able to write more
  complex metrics reports via SQL and the [ActiveRecord Query Interface][11]
  will be possible in the future. If you're a power user, want to collect a
  ton of metrics, or want to do more advanced reporting such as grouping metrics
  by day of the week, etc., then you'll want to go this direction. The
  `:log_file` option is provided as a very stripped down, simple choice if all
  you want for you app metrics is simplicity.
* `:email_options` - the list of default options for metrics emails. Any options
  you passed to the `HowSlow::Mailer::metrics_email` will override these
  defaults.

## FAQ

* **Why not write the logs to a database?
  * First of all, performance and simplicity are top priorities, and writing to
    the file system is fast.
  * Second of all, [ActiveRecord support][10] is planned, but not currently
    implemented.

[1]: http://en.wikipedia.org/wiki/Federal_Information_Security_Management_Act_of_2002
[2]: https://github.com/etsy/statsd/
[3]: http://api.rubyonrails.org/classes/ActiveSupport/Notifications.html#label-Subscribers
[4]: http://newrelic.com/
[5]: https://github.com/normalocity/how_slow/blob/master/lib/how_slow/reporter.rb
[6]: https://www.heroku.com/
[7]: https://devcenter.heroku.com/articles/read-only-filesystem
[9]: http://www.google.com/analytics/
[10]: https://github.com/normalocity/how_slow/issues/8
[11]: http://guides.rubyonrails.org/active_record_querying.html
