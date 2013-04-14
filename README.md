# how_slow

Allows you to easily collect Rails app performance metrics to a log file.

## Why?

This gem began as a way to easily collect performance metrics for Rails
controller actions.

"Why not use [statsd][2] or [NewRelic][4]?" you might ask.

* I work in a [FISMA][1]
  compliant workplace where we can't simply ship our logs off to [NewRelic][4], or
  really **any** 3rd party for that matter because of the potential that
  security problems or programming errors could result in sensitive, private
  medical data being leaked to a 3rd party. For this reason alone **every**
  single hosted metrics collection and analytics tool was a non-starter for us
  unless the vendor was willing to let us self-host their software for a
  reasonable price.
* Most of the Rails apps I work on are maintained by 1-2 programmer teams, and
  so as flashy and cool as all the metrics and performance analysis tools look
  on the surface, we really just need to know a few basic facts about our apps'
  performance. [statsd][2], for example, would
  be overkill for this.

In other words, I needed a simple way to capture performnace metrics for simple
Rails apps, without a lot of trouble, and without potentially exposing log data
to a 3rd party.

In addition to these concerns I wanted the logging of metrics to be fast and to
have the option of it being non-database specific. Many of the alternate gems
you might try to use for this purpose write to [redis][8] or a relational database.
Right now the `how_slow` gem only supports writing serialized JSON strings to a
file, one metric per line. This will be as fast as any other disk I/O that you
would make to any other disk-based storage.

Finally, I didn't like that [statsd][2], as powerful as it is, required the setup
and maintenance of another complete server. Yes, I totally get that [statsd][2] is
an all-in-one solution that can track any stat from anywhere within your
organization, but I just didn't need anything that fancy right now.

## Usage

Simply add `how_slow` to your `Gemfile`

    gem 'how_slow'

## Configuration

Currently `how_slow` only supports two configuration options.

* `:event_subscriptions` - an array of regex patters used to match actions. For
  more on how that works, see the documentation on
  [ActiveSupport::Notifications Subscribers][3]
* `:logger_filename` - the name of the file to write the metrics logs. The
  default is `metrics.log`, which winds up placing the file under
  `"#{Rails.root}/log/metrics.log"`

## Getting your metrics data

After collecting your app metrics data how do you get useful data back? Right
now, in the gems early days, you can only get back either a hash of every single
metric that has been recorded by your app, or a list of the slowest actions.
Simply call...

    HowSlow.rebuild_metrics

...to tell `how_slow` to read the recorded metrics from the log file. Then...

    HowSlow.slowest_actions(10, 7.days_ago)

...where the first parameter tells `how_slow` to give me only the 10 slowest
actions within the last 7 days. Both of these arguments are optional. If you
specify no arguments then by default `how_slow` will tell you the slowest 5
actions of all time (not terribly userful, so you probably want to time-limit
the returned list).

To get the full list of all metrics recorded by `how_slow`, simply call...

    HowSlow.metrics

...some point after you've called `rebuild_metrics`, and it will give you a hash
of all recorded metrics, the format of which is [documented here][5].

With these simple lines of code you should be able to easily build email-based
reporters that send you an automated email via a cron+rake task once a week,
giving you a simple, actionable report that costs you basically nothing.

## FAQ

* If this uses a log file can I use this on [Heroku][6]?
  * Sure, but for now you will need to manually copy your log file to someplace
    more permanent due to Heroku's [read-only (a.k.a. ephemeral) file system][7].
* Why not write the logs to a database or [redis][9] or something more that a
  flat file?
  * Well, for one, performance and simplicity are top priorities.
  * On the other hand, I'd like to add support for that sort of thing in the
    future, but only when it's asked for. I don't want to make a simple gem into
    a complicated gem without someone actually requesting it.
* Is there any way I can easily feed the JSON data into a charting/visualization
  tool?
  * Collection and visualization are really two separate problems. If you want
    to massage the data that comes out of `how_slow` so that it will fit into
    the time series charting library of your choice then that's all well and
    good. However, in order to keep `how_slow` simple I think it's best not to
    marry it to any specific charting solution. Also, I don't thing `how_slow`
    should concern itself with anything other than collection and very simple
    reporting/filting of metrics data.

## Thanks!

Thanks for checking out `how_slow`. It is still in its early days.

[1]: http://en.wikipedia.org/wiki/Federal_Information_Security_Management_Act_of_2002
[2]: https://github.com/etsy/statsd/
[3]: http://api.rubyonrails.org/classes/ActiveSupport/Notifications.html#label-Subscribers
[4]: http://newrelic.com/
[5]: https://github.com/normalocity/how_slow/blob/master/lib/how_slow/reporter.rb
[6]: https://www.heroku.com/
[7]: https://devcenter.heroku.com/articles/read-only-filesystem
[8]: http://redis.io/
