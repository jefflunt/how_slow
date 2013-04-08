# how_slow

Allows you to easily collect Rails app performance metrics to a log file.

## Back story

This gem began as a way to easily collect performance metrics for Rails
controller actions.

"Why not use statsd or NewRelic?" you might ask.

* I work in a [FISMA](http://en.wikipedia.org/wiki/Federal_Information_Security_Management_Act_of_2002)
  compliant workplace where we can't simply ship our logs off to NewRelic, or
  really **any** 3rd party for that matter, because of the potential data
  security problems should a programming error result in sensitive data being
  leaked to a 3rd party.
* Most of the Rails apps I work on are maintained by 1-2 programmer teams, and
  so as flashy and cool as all the metrics and performance analysis tools look
  on the surface, we really just need to know a few basic facts about our apps'
  performance. [statsd](https://github.com/etsy/statsd/), for example, would
  be overkill.

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
  default is to simply subscribe to **all** `ActionController` events.

The gem is currently in a very early pre-release stage where only the collection
and storage of metrics is currently implemented. My next task is to work on
reporting of those metrics, which I will also be doing in JSON, simply because
it's a straight forward form that is easy to read and easy to write.

I'm choosing to make this gem extremely bare and simple on purpose, only adding
features beyond what I've just described as they are asked for and proven useful
and not before. I think it's too easy to let the the desire for fancy charts
and graphs override the reality that all that is really necessary is a simple
tool that works well.
