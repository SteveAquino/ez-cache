# EzCache

Easy caching for your Rails Controllers using ETag headers.

## Usage

In your controller:

```ruby
# app/controllers/dummy_controller.rb

class DummyController < ApplicationController
  include EzCache

  ez_cache_action key: 'dummmy/index',
                  params: [:q],
                  only: [:index]

  ez_cache_action key: 'dummmy/protected',
                  headers: [:authorization],
                  only: [:protected]

  # Returns the current time
  def index
    render json: {time: Time.now}
  end

  # Checks the authorization header
  def protected
    auth = request.headers['HTTP_AUTHORIZATION']

    if auth =~ /sekret/
      render json: {success: "You're in!"}
    else
      render json: {error: 'Unauthorized'}, status: 401
    end
  end

  # Clears all the caches on demand
  def clear_cache
    Rails.cache.clear('dummy/index')
    Rails.cache.clear('dummy/protected')
  end
end
```

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'ez-cache'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install ez-cache
```

## Contributing

- Fork the repo
- Make a branch
- Open a pull request against this repo

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
