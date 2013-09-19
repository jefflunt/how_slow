### v0.4.0

#### Breaking changes (versus v0.3.x):

- `Reporter#slowest_actions_by` method now takes an options hash for optional
  parameters. See [#18](https://github.com/jefflunt/how_slow/issues/18) If
  you're calling this method directly in your code anywhere (in a rake task, or
  in your own reporting method, for example), then you'll want to audit your
  usage to use a hash.

#### Other code changes

- `'keep_since' => 'retention`
  The use of the name `keep_since` to denote a retention period, or a period of
  time after which metrics should be included for reporting purposes have been
  replaced with the term `retention`.

### v0.3.0

**NOTE:** v0.3.x is no longer built against Rubinius.

#### Breaking changes (versus v0.2.x):

- Refactored the `HowSlow::config` options - you will **definitely**
  [want to take a look at the new structure](https://github.com/jefflunt/how_slow/blob/v0.3.0.pre.6/lib/how_slow/setup.rb#L3), 
  as they are very likely to break your previous use of `HowSlow 0.2.0`
- Possible breakage of Rails 4 support. More specifically I changed the
  `how_slow.gemspec` file to **exclude** Rails 4 support (for now)
- No longer support Rails 3.0 (bumped minimum version to Rails 3.1)
- Changed `HowSlow` from a `Rails::Railtie` to a `Rails::Engine` in order
  to make the mailer views easily available and override-able in the
  app that is using `HowSlow`

#### Other code changes

- Added [email report support!](https://github.com/normalocity/how_slow/issues/12)
- Added `#to_default_email_string` methods to the various metric types as a convenience
  method for getting their values in a human-readable format in email
- Added a rake task - `how_slow:metrics_email` for sending an email with a metrics
  report. Suitable for consumption by `cron` or something similar that is outside
  of your application.
- The `actionmailer` gem is now required, but this shouldn't be a big deal, because
  if you're already using Rails then you already have this installed
- Changed the way that files are "required" in order to support Ruby 1.8 load paths
- Building against [eight different Ruby implementations via TravisCI](https://travis-ci.org/normalocity/how_slow)
  from 1.8-2.0, including MRI, JRuby, and Rubinius

#### Documentation changes

- Updated README to reflect latest code changes and usage recommendations
- Updated all the code-level documentation to reflect the latest 0.3.0 functionality
- Slightly changed the gem description

### v0.2.0

#### Breaking changes (versus v0.1.x):

- The logger changes the JSON attribute `type` to `type_name` so as not to
  collide with the deprecated `type` method in Ruby. This means that any metrics
  you collected using the `0.1.x` version of the gem will essentially be
  ignored. You might just want to delete them now.
- The `slowest_action` method has been replaced. First, it is no longer a method
  on the module. Second, it has been renamed to `slowest_actions_by` and allows
  you to specify which measurement (`total_runtime`, `db_runtime`,
  `view_runtime`, or `other_runtime`). Otherwise the method still accepts the
  `number_of_actions` and `keep_since` arguments, which work the same way as
  they did previously.
- Moved the responsibility of collecting and logging metrics out of the module
  itself and into subclasses that wrap the `action` and `counter` metrics types.
  Like an ORM, these classes wrap the data in a given metric with a Ruby object
  and make the metric's data available as attributes.
- Some of the hash keys in metrics have been changed from strings to symbols.
  Check the structure if code that depends on these hashes seems to suddenly
  break.

#### Other changes

- To supoprt the new `counter` metric type, I added the
  `HowSlow::Reporter#sum_counters_by` method, which allows you to get metrics
  reports on counters in a fashion similar to `action` metrics.
- There is a new metric type, a counter, which is used to count anything you
  want it to count.
 The default `keep_since` value for the `slowest_actions_by` method has been
  changed from `nil` to `7.days.ago`.
- Completely rewrote and expanded the test suite to better organize it, make it
  more comprehensive, and overall much more readable.
