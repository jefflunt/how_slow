## v0.2.0

### Breaking changes (versus v0.1.x):

* The logger changes the JSON attribute `type` to `type_name` so as not to
  collide with the deprecated `type` method. This will require you to **purge**
  any existing `how_slow` logs you have because they will not be successfully
  parsed in v0.2.0 reporter.

### Other changes

* Moved the responsibility of collecting and logging metrics out of the module
  itself and into subclasses that wrap the `action` and `counter` metrics types.
  
