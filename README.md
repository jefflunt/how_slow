# how_slow

Collect Rails app performance and usage metrics without relying on 3rd party
services or setting up a separate logging server.

===================

**The basics**

* This is the **README** *for v0.3.0*
* `how_slow` uses **[Semantic Versioning](http://semver.org/)**
* This gem now has a **[mailing list](https://groups.google.com/forum/#!forum/how_slow-gem)**
for questions and support issues
* Verified **bugs** should be [opened directly on github](https://github.com/jefflunt/how_slow/issues)
* **Install** - `gem 'how_slow'`
* *Development ests* - `rake test`
* `how_slow` is [built against several ruby implementations](https://travis-ci.org/jefflunt/how_slow). See `.travis.yml`

===================

## Reasons to use `how_slow`

* You want a solution that doesn't rely on a 3rd party, simplifying your
  application dependencies.
* You're in an environment where the risk of sensitive data accidentally being
  leaked to a 3rd party service is unacceptable. So, you can't use [NewRelic][4].
* You don't need all the fancy charts and graphs of [NewRelic][4] and you're
  not afraid of editing some simple config files to get *just* the metrics you
  want.
* The idea of setting up and maintaining a [statsd][2] server, along with a
  graphing/charting software stack, just to display your statistics sounds like
  a waste of time.
* 99% of your needs could be fulfilled by a simple, weekly email that lists your
  slowest controller actions and your most used features.

## Metrics Storage

### Performance stats

`how_slow` will capture performance metrics for every single controller action
in your Rails app by default, and place them in the file:

    %Rails.root%/log/metrics.log

You can [change](#configuration) the list of controller actions captured.

You can [change](#configuration) the name of this file.

### Usage stats

Want to count logins?

In your controller code:

    # Use the `count` method to count an arbitrarily named metric
    HowSlow::Collector::count('user_login')

Specify an optional number parameter to count up or down by any whole number:

    # e.g. customer ordered three items:
    HowSlow::Collector::count('total_items_ordered', 3)

    # e.g. customer returned two items:
    HowSlow::Collector::count('total_items_ordered', -2)
    
    # e.g. count them separately
    HowSlow::Collector::count('total_items_ordered', 3)
    HowSlow::Collector::count('total_items_returned', 2)

## Metrics Retrieval

### Via email:

    # rake task - this will ONLY use the defaults specified in your
    # `config/environment.rb` OR `config/environments/[Rails.env]` file
    rake how_slow:metrics_email

    # in code - this allows you to override the defaults in your
    # environment file
    HowSlow::Mailer.metrics_email(options)
    
A sample of a real email generated from this:

```text
Slowest 100 requests, sorted by total_runtime:
--------------------
datetime :: controller/action    total / db / view / other in milliseconds
--------------------
2013-08-12T15:47:46+00:00 :: sections/show      2355 / 92 / 1693 / 569
2013-08-12T15:45:35+00:00 :: sections/show      1276 / 57 / 913 / 305
2013-08-11T00:03:20+00:00 :: log_books/index    598 / 10 / 585 / 2
2013-08-17T12:38:52+00:00 :: sections/show      469 / 51 / 409 / 7
2013-08-14T21:24:01+00:00 :: sections/show      460 / 20 / 431 / 7
2013-08-14T05:40:08+00:00 :: sections/show      459 / 32 / 419 / 7
2013-08-17T12:38:53+00:00 :: sections/show      458 / 35 / 415 / 7
2013-08-13T03:42:57+00:00 :: sections/show      408 / 27 / 337 / 43
2013-08-13T01:24:11+00:00 :: sections/show      392 / 22 / 362 / 7
2013-08-15T01:37:02+00:00 :: sections/show      387 / 40 / 339 / 7

...(summarized)...

Counters sorted by alpha_asc:
--------------------
views.homepage: 2226
views.login.total: 2
views.sections.show.by-user.anonymous: 73
views.sections.show.by-provider.facebook: 3
views.sections.show.total: 76
```

You can name your counters whatever you like, but since I like to get my sorted by
alphebetical order, ascending, I name them as if they were namespaces, in order to
group similar counter metrics together.

* See the `lib/how_slow/mailer.rb` class for which options are availble. It's
  possible to specify the number of metrics reported, the sort order, and how
  far back in time you want the report to cover.
* Configure default email options in your environemnt file. See
  `lib/how_slow/setup.rb` for a list of defaults.

### There's also a `Reporter` class to get metrics in-app:

See `lib/how_slow/reporter.rb` for more examples and documentation on default options:

    reporter = HowSlow::Reporter.new
    reporter.slowest_actions_by(:total_runtime)
    => [HowSlow::Metrics::Action<# >, ...]   # sorted by #total_runtime, DESC
    
    reporter.slowest_actions_by(:db_runtime, { :number_of_actions => 50, :retention => 1.month.ago})
    => [HowSlow::Metrics::Action<# >, ...]   # the 50 longest DB actions in the last month
    
    reporter.sum_counters_by('user_login')   # retrieve the value of any counter
    => 526354

    reporter.sum_counters_by('user_login', 1.month.ago) # restrict counts to just the last month
    => 1254

## Configuration

**Basic options:**

* `:event_subscriptions` - an array of regex patters used to match actions. For
  more on how that works, see the documentation on
  [ActiveSupport::Notifications Subscribers][3]. `how_slow` will default to
  tracking **all** controller actions automatically if you don't explicitly set
  this option.
* `:logger_filename` - the name of the file used to write metrics data. The
  default is `metrics.log`, which winds up placing the file under
  `"#{Rails.root}/log/metrics.log"`
* `:storage` - the storage method. Right now the default (and only option) is
  `:log_file`, however support for collecting metrics into your database via an
  `:active_record` option [has been requested][10]. That means being able to
  write more complex metrics reports via SQL and the [ActiveRecord Query Interface][11]
  will be possible in the future. If you're a power user, want to collect a
  ton of metrics, or want to do more advanced reporting such as grouping metrics
  by day of the week, etc., then you'll want to go this direction. The
  `:log_file` option is provided as a very stripped down, simple choice if all
  you want for you app metrics is simplicity.

**Metrics email options:**

* `:email_sender_address` - the email address that will appear in the `from` field
* `:email_recipients` - the list of email address in the `to` field
* `:email_subject` - the `subject` of the metrics report email
* `:email_actions_sort` - the attribute by which to sort the action metrics in the report -
  one of `[:total_runtime, :db_runtime, :view_runtime]`
* `:email_actions_retention` - how far back in time to consider action metrics for
  the email report, such as `7.days` or `1.month`
* `:email_counters_events` - a list of the events to include in the report - the
  default is `nil`, which means "give me all the counter values"
* `:email_counters_sort` - how to sort the counters - one of
  `[:alpha_asc, :alpha_desc, :numeric_asc, :numeric_desc]`
* `:email_counters_retention` - how far back in time to consider counter metrics for
  the email report, such as `7.days` or `1.month`

**Example configuration:**

In your app's `config/environments/production.rb`, you might use something like the
options below to send a weekly performance and usage statistics email:

    HowSlow.configure(
      :email_recipients        => %w(admin@example.com developers@example.com),
      :email_sender_address    => "how_slow_reporter@example.com",
      :email_subject           => "Weekly metrics report",
      :email_actions_retention => 7.days,
      :email_actions_max       => 100
    )
    
Email is sent via [ActionMailer][8]

[1]: http://en.wikipedia.org/wiki/Federal_Information_Security_Management_Act_of_2002
[2]: https://github.com/etsy/statsd/
[3]: http://api.rubyonrails.org/classes/ActiveSupport/Notifications.html#label-Subscribers
[4]: http://newrelic.com/
[5]: https://github.com/normalocity/how_slow/blob/master/lib/how_slow/reporter.rb
[6]: https://www.heroku.com/
[7]: https://devcenter.heroku.com/articles/read-only-filesystem
[8]: https://github.com/rails/rails/tree/master/actionmailer
[9]: http://www.google.com/analytics/
[10]: https://github.com/normalocity/how_slow/issues/8
[11]: http://guides.rubyonrails.org/active_record_querying.html
