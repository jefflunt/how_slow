## v0.2.0

### Breaking changes (versus v0.1.x):

* The logger changes the JSON attribute `type` to `type_name` so as not to
  collide with the deprecated `type` method. This will require you to **purge**
  any existing `how_slow` logs you have because they will not be successfully
  parsed in v0.2.0 reporter.
* The `slowest_action` method has been replaced. First, it is no longer a method
  on the module. Second, it has been renamed to `slowest_actions_by` and allows
  you to specify which measurement (`total_runtime`, `db_runtime`,
  `view_runtime`, or `other_runtime`). Otherwise the method still accepts the
  `number_of_actions` and `keep_since` arguments, which work the same way as
  they did previously.
* Some of the hash keys in metrics have been changed from strings to symbols.
  Check the structure if code that depends on these hashes seems to suddenly
  break.

### Other changes

* Moved the responsibility of collecting and logging metrics out of the module
  itself and into subclasses that wrap the `action` and `counter` metrics types.
* There is a new metric type, a counter, which is used to count anything you
  want it to count.
* The default `keep_since` value for the `slowest_actions_by` method has been
  changed from `nil` to `7.days.ago`.
  
