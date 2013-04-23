## v0.2.0

### Breaking changes (versus v0.1.x):

* The logger changes the JSON attribute `type` to `type_name` so as not to
  collide with the deprecated `type` method in Ruby. This means that any metrics
  you collected using the `0.1.x` version of the gem will essentially be
  ignored. You might just want to delete them now.
* The `slowest_action` method has been replaced. First, it is no longer a method
  on the module. Second, it has been renamed to `slowest_actions_by` and allows
  you to specify which measurement (`total_runtime`, `db_runtime`,
  `view_runtime`, or `other_runtime`). Otherwise the method still accepts the
  `number_of_actions` and `keep_since` arguments, which work the same way as
  they did previously.
* Moved the responsibility of collecting and logging metrics out of the module
  itself and into subclasses that wrap the `action` and `counter` metrics types.
  Like an ORM, these classes wrap the data in a given metric with a Ruby object
  and make the metric's data available as attributes.
* Some of the hash keys in metrics have been changed from strings to symbols.
  Check the structure if code that depends on these hashes seems to suddenly
  break.

### Other changes

* To supoprt the new `counter` metric type, I added the
  `HowSlow::Reporter#sum_counters_by` method, which allows you to get metrics
  reports on counters in a fashion similar to `action` metrics.
* There is a new metric type, a counter, which is used to count anything you
  want it to count.
 The default `keep_since` value for the `slowest_actions_by` method has been
  changed from `nil` to `7.days.ago`.
* Completely rewrote and expanded the test suite to better organize it, make it
  more comprehensive, and overall much more readable.
