# 0.5.1

* Fix broken tests.

# 0.5.0

* Refactor `Hobbit::ErrorHandling` according to the recent changes on
`Hobbit::Response`.
* Fix tests.
* Fix `Hobbit::Filter`. It wasn't filtering actions if an empty before (or
after) filter was defined.

# 0.4.2

* Make `environment`, `development?`, `production?` and `test?` available
in class context (in `Hobbit::Environment`).

# 0.4.1

* Fix `Hobbit::ErrorHandling`. Now, when an exception is raised, the `error`
block is executed in the context of the object, not the class.
* Fix error handling and filter specs.

# 0.4.0

* Fix `Hobbit::Filter`. Now it works with `halt`, introduced in `hobbit` 0.4.0.

# 0.3.0

* Fix `hobbit-contrib.gemspec`: add `erubis` and remove redundant dependencies.
* Remove `Hobbit::AssetTag` module. It's not hard to write `link` and `script`
tags.
