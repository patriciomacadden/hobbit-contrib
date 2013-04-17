# Hobbit::Contrib

[![Build Status](https://travis-ci.org/patriciomacadden/hobbit-contrib.png?branch=master)](https://travis-ci.org/patriciomacadden/hobbit-contrib)
[![Code Climate](https://codeclimate.com/github/patriciomacadden/hobbit-contrib.png)](https://codeclimate.com/github/patriciomacadden/hobbit-contrib)

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

## Usage

Each extension may have its own usage. In general, including (or extending) the
module will be enough.

```ruby
require 'hobbit'
require 'hobbit/contrib'

class App < Hobbit::Base
  # define your application
end
```

## Available extensions

### Hobbit::EnhancedRender

This module extends the functionality of `Hobbit::Render`. To use this extension
just include the module:

```ruby
require 'hobbit'
require 'hobbit/contrib'

class App < Hobbit::Base
  include Hobbit::EnhancedRender

  get '/' do
    # index will become views/index.erb
    # use a layout (named 'layout'. It will become views/layouts/layout.erb)
    render 'index', {}, layout: 'layout'
  end
end
```

#### Available methods

* `template_engine`: Returns the default template engine being used for this
application. By default is `erb`.
* `layout_path`: Returns the layout path according to the given template. For
instance, `layout_path('layout')` will become `views/layouts/layout.erb`
* `view_path`: Returns the view path according to the given template. For
instance, `view_path('index')` will become `views/index.erb`
* `render`: It's the same as in `Hobbit::Render`, but you can render templates
with a layout (See the example above).
* `partial`: It's the same as `render`, but expands the template name to the
views path, except that the template name will start with an underscore. For
instance, if you call `partial 'partial'`, the path will become
`views/_partial.erb`

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

See the [LICENSE](https://github.com/patriciomacadden/hobbit-contrib/blob/master/LICENSE).