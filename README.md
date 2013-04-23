# how_slow

Easily collect Rails app performance metrics without relying on 3rd party
services or setting up a separate logging server.

## Why?

This gem began as a way to easily collect performance metrics for Rails
controller actions.

"Why not use [statsd][2] or [NewRelic][4]?" you might ask.

* I work in an environment where the risk of sensitive data accidentally being
  sent to a 3rd party service is unacceptable. So, can't use [NewRelic][4].
* I want a solution that doesn't rely on a 3rd party at all, simplifying my
  application dependencies.
* Most of the Rails apps I work on are maintained by 1-2 programmer teams, and
  so as flashy and cool as all the metrics and performance analysis tools look
  on the surface, we really just need to know a few basic facts about our apps'
  performance. [statsd][2], for example, would
  be overkill for this.
* I don't like the idea of having to maintain a [statsd][2] server along with
  a generic graphing/charting software stack, just to get some basic usage and
  performance numbers from my apps.
* I also don't enjoy needing to go to SQL or the Rails console to get this
  information. `how_slow` is a **great** middle ground.

## Installing

Simply add `how_slow` to your `Gemfile`

    gem 'how_slow'

## Storing your metrics data

### Performance stats

By default `how_slow` will automatically capture performance metrics for every
single controller action in your Rails app. It stores this information in:

    "#{Rails.root}/log/metrics.log"

You can [configure](#configuration) the name of the file if you wish.

You can [configure](#configuration) the list of controller actions for which you collect
performance metrics.

### Usage stats

Curious how many times users are hitting your homepage or hitting the "login"
button? Sure, you could track this with [Google Analytics][9], but this once
again forces your app to rely upon a 3rd party.

Insted you can do this in your controller code...

    HowSlow::Collector::count('user_login', 1)

...where `'user_login'` is an arbitrary string that you make up, and `1` is the
count for this event. Since the user is logging in `1` time we count this as
`1`. If instead you wanted to count the number of cookies you took from the
cookie jar when you visitied `/cookies/take?num=3` you could do something like
this in your controller code...

    HowSlow::Collector::count('cookies_eaten', params[:num]) # <= 3 cookies

...and HowSlow would show you that at this date and time you ate 3 cookies.

## Getting your metrics data

### Performance stats

Storing your data is only half the problem - now that you have all those metrics
you want to get a simple report. Something like:

    reporter = HowSlow::Reporter.new
    reporter.slowest_actions_by(:total_runtime)

The `Reporter::slowest_actions_by` method will, by default, give you the `5`
slowest actions, sorted by `:total_runtime` in the last 7 days. This is useful
for an automated email to alert you of the slowest parts of your app.

If instead you wanted a daily email with the slowest 10 actions, you would call:

    reporter.slowest_actions_by(:total_runtime, 10, 1.day.ago)

...and if you wanted to know the most DB or view intensive actions you would
call:

    reporter.slowest_actions_by(:db_runtime, 10, 1.day.ago)
    # OR
    reporter.alowest_actions_by(:view_runtime, 10, 1.day.ago)

### Usage stats

If you wanted to know the number of user logins this week you would call:

    reporter.sum_counters_by('user_login')
    => 235

If you wanted to know how many cookies you at this week you would call:

    reporter.sum_counters_by('cookies_eaten')
    => 17

By default this method will only sum the counter metrics within the last 7 days.
This makes it useful for a weekly email where the default are the usage numbers
for the previous week.

If instead you wanted to know how many cookies you ate in the last 24 hours, you
would call:

    reporter.sum_counters_by('cookies_eaten', 1.day.ago)
    => 3

Both of the reporting methods accept the standard ActiveSupport core extentions
for calculating times in the past, such as `7.days.ago` or `5.minutes.ago`, etc.

## Configuration

Currently `how_slow` supports three configuration options.

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

## Testing

If you want to run the tests for this gem do the following:

    bundle install
    bundle exec rake test

## FAQ

* Is this appropriate for prodcution use? Will there be much overhead?
  * **Yes**, it's appropriate for production use. Performance metrics are only
    really useful IMHO if they are measuring your actual production system.
  * It's hard to say exactly how much overhead it will add, but it's very
    minimal. We're just writing to a log file - it's not that complex. We're
    talking single-digit millisecond or sub-millisecond overhead here.
  * Running the simple reporting methods may take a little more time, and is
    dependent largely on the size of your log file. The more data in your log
    the longer it will take to report on it. For anything but gigabytes of logs,
    however, we're talking about seconds (not minutes) to report on the data,
    so long as you have enough free memory on your server to do so. The memory
    issue can be addressed in two ways: rotate your logs regularly and only
    store recent data, or wait until [ActiveRecord storage][10] is added so you
    can write your metrics reports for an added layer of control.
* Why not write the logs to a database or [redis][8] or something more that a
  flat file?
  * First of all, performance and simplicity are top priorities.
  * Second of all, [ActiveRecord support][10] is planned, so don't worry - it's
    coming.
* Is there any way I can easily feed the JSON data into a charting/visualization
  tool?
  * Collection and visualization are really two separate problems. If you want
    to massage the data that comes out of `how_slow` so that it will fit into
    the time series charting library of your choice then that's all well and
    good. However, in order to keep `how_slow` simple I think it's best not to
    marry it to any specific charting solution. Also, I don't think `how_slow`
    should concern itself with anything other than collection your metrics and
    making them available to you.
* If this uses a log file can I use this on [Heroku][6]?
  * Sure, but you will need to periodically copy your log file to someplace more
    permanent due to Heroku's [read-only (a.k.a. ephemeral) file system][7]
    or else it may get deleted at [Heroku's][6] whim.
  * Writing your log file to S3 is probably not a good idea here, since that
    involves some network overhead, and will almost certainly add significant
    logging overhead.

## Thanks!

Thanks for checking out `how_slow`.

[1]: http://en.wikipedia.org/wiki/Federal_Information_Security_Management_Act_of_2002
[2]: https://github.com/etsy/statsd/
[3]: http://api.rubyonrails.org/classes/ActiveSupport/Notifications.html#label-Subscribers
[4]: http://newrelic.com/
[5]: https://github.com/normalocity/how_slow/blob/master/lib/how_slow/reporter.rb
[6]: https://www.heroku.com/
[7]: https://devcenter.heroku.com/articles/read-only-filesystem
[8]: http://redis.io/
[9]: http://www.google.com/analytics/
[10]: https://github.com/normalocity/how_slow/issues/8
[11]: http://guides.rubyonrails.org/active_record_querying.html
