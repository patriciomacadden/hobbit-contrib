# Hobbit::Contrib [![Build Status](http://img.shields.io/travis/patriciomacadden/hobbit-contrib.svg)](https://travis-ci.org/patriciomacadden/hobbit-contrib) [![Code Climate](http://img.shields.io/codeclimate/github/patriciomacadden/hobbit-contrib.svg)](https://codeclimate.com/github/patriciomacadden/hobbit-contrib) [![Code Climate Coverage](http://img.shields.io/codeclimate/coverage/github/patriciomacadden/hobbit-contrib.svg)](https://codeclimate.com/github/patriciomacadden/hobbit-contrib) [![Dependency Status](http://img.shields.io/gemnasium/patriciomacadden/hobbit-contrib.svg)](https://gemnasium.com/patriciomacadden/hobbit-contrib) [![Gem Version](http://img.shields.io/gem/v/hobbit-contrib.svg)](http://badge.fury.io/rb/hobbit-contrib)

Contributed Hobbit extensions.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hobbit-contrib', require: 'hobbit/contrib'
# or this if you want to use master
# gem 'hobbit-contrib', github: 'patriciomacadden/hobbit-contrib', require: 'hobbit/contrib'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install hobbit-contrib
```

### Optional dependencies

* [mote](https://github.com/soveran/mote) if you want to use `Hobbit::Mote`.
* [tilt](https://github.com/rtomayko/tilt) if you want to use `Hobbit::Render`.

## Usage

Each extension may have its own usage. In general, including the module will be
enough.

```ruby
require 'hobbit'
require 'hobbit/contrib'

class App < Hobbit::Base
  # include hobbit session extension
  include Hobbit::Session

  # define your application
end
```

## Available extensions

### Hobbit::Environment

This extension allows you to control the application environment by using the
provided methods. To use this extension just include the module:

```ruby
require 'hobbit'
require 'hobbit/contrib'

class App < Hobbit::Base
  include Hobbit::Environment

  get '/' do
    "currently in #{environment}"
  end
end

run App.new
```

#### Available methods

* `environment`: Returns the current environment. By default is
`ENV['RACK_ENV']`.
* `development?`: Returns true if the current environment is `:development`.
* `production?`: Returns true if the current environment is `:production`.
* `test?`: Returns true if the current environment is `:test`.

**Note**: All methods are available at class and instance context.

### Hobbit::ErrorHandling

This extension provides a way of handling errors raised by your application. To
use this extension just include the module:

```ruby
require 'hobbit'
require 'hobbit/contrib'

class App < Hobbit::Base
  include Hobbit::ErrorHandling

  error Exception
    exception = env['hobbit.error']
    exception.message
  end

  get '/' do
    raise Exception, 'Oops'
  end
end

run App.new
```

#### Available methods

* `errors`: Returns a hash with the exceptions being handled and its
corresponding handler.
* `error`: Sets a handler for a given exception.

**Note**: If you define more than one handler per exception the last one
defined will have precedence over the others.

### Hobbit::Filter

This extension provides a way of calling blocks before and after the
evaluation of a route (just like sinatra's filters). To use this extension just
include the module:

```ruby
require 'hobbit'
require 'hobbit/contrib'

class App < Hobbit::Base
  include Hobbit::Filter

  def authenticate_user!
    # ...
  end

  before do
    authenticate_user!
  end

  get '/' do
    # ...
  end
end

run App.new
```

#### Available methods

* `after`: Sets an after filter. Optionally, you can specify a route.
* `before`: Sets a before filter. Optionally, you can specify a route.

**Note**: It is recommended to include `Hobbit::Filter` before
`Hobbit::ErrorHandling` if you want to use both extensions.

### Hobbit::Mote

This module provides rendering to your hobbit application using [mote](https://github.com/soveran/mote).
To use this extension just include the module:

```ruby
require 'mote'
require 'hobbit'
require 'hobbit/contrib'

class App < Hobbit::Base
  include Hobbit::Mote

  get '/' do
    # will render views/index.mote using views/layouts/application.mote as layout
    render 'index'
  end
end
```

#### Available methods

* `default_layout`: Returns the name of the default layout (Override to use
another layout).
* `find_template`: Returns the path to a template (Override for multiple views
paths lookup).
* `layouts_path`: Returns the layouts path (Override to change the layouts
directory).
* `partial`: Renders the given template using tilt (without a layout).
* `render`: Renders the given template using tilt. You can pass a `layout`
option to change the layout (or set to `false` to not use one).
* `views_path`: Returns the views path (Override to change the views
directory).

NOTE: Use `{{content}}` within your layout to yield the rendered page.

### Hobbit::Render

This module provides rendering to your hobbit application using
[tilt](https://github.com/rtomayko/tilt). To use this extension just include
the module:

```ruby
require 'tilt'
require 'hobbit'
require 'hobbit/contrib'

class App < Hobbit::Base
  include Hobbit::Render

  get '/' do
    # will render views/index.erb using views/layouts/application.erb as layout
    render 'index'
  end
end
```

#### Available methods

* `default_layout`: Returns the name of the default layout (Override to use
another layout).
* `find_template`: Returns the path to a template (Override for multiple views
paths lookup).
* `layouts_path`: Returns the layouts path (Override to change the layouts
directory).
* `partial`: Renders the given template using tilt (without a layout).
* `render`: Renders the given template using tilt. You can pass a `layout`
option to change the layout (or set to `false` to not use one).
* `template_engine`: Returns the template engine beign used (Override to use
other template engine).
* `views_path`: Returns the views path (Override to change the views
directory).

### Hobbit::Session

This module provides helper methods for handling user sessions. To use this
extension just include the module:

```ruby
require 'hobbit'
require 'hobbit/contrib'

class App < Hobbit::Base
  include Hobbit::Session
  use Rack::Session::Cookie, secret: SecureRandom.hex(64)

  post '/' do
    session[:name] = 'hobbit'
  end

  get '/' do
    "Hello #{session[:name]}!"
  end
end
```

#### Available methods

* `session`: Returns the user's session.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

See the [LICENSE](https://github.com/patriciomacadden/hobbit-contrib/blob/master/LICENSE).
