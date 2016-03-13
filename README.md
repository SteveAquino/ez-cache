# EzCache

Easy caching for your Rails Controllers using ETag headers.  Take advantage of browser level caching and make your APIs **instantaneous!**

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

## Usage

The easiest usage is to simply call `ez_cache_action` at the top of your controller with an action name and key:

```ruby
# app/controllers/posts_controller.rb

class PostsController < ApplicationController
  include EzCache
  ez_cache_action :index, 'posts/index'
end
```

Now requests to your controller will return an `ETag` header that corresponds with the given cache key:

```bash
$ curl -i http://localhost:3000/posts

HTTP/1.1 200 OK
ETag: W/"7a6d57b4a84fa1754e8c9af6d9a91633"
```

Now setting the `If-None-Match` header on subsequent requests will return a 304 Not Modified response:

```bash
curl -i http://localhost:3000/posts \
     -H 'If-None-Match: W/"7a6d57b4a84fa1754e8c9af6d9a91633"'

HTTP/1.1 304 Not Modified
ETag: W/"7a6d57b4a84fa1754e8c9af6d9a91633"
```

To clear the cache, simply clear the key from the Rails cache:

```ruby
Rails.cache.delete('posts/index')
```

### Caching with Params

Usually you need to return different data based on some params passed to the request.  For example, your controller might use a `:page` param to return paginated results.  By default EzCache will ignore parameters, but you can
specify parameters to include in the cache key by passing the `:params` option
to `ez_cache_action`:

```ruby
# app/controllers/posts_controller.rb

class PostsController < ApplicationController
  include EzCache
  ez_cache_action :index, 'posts/index', params: [:page]
end
```

Now the server will return a different ETag based on the `:page` param sent in.

```bash
# Request for page 1
$ curl -i http://localhost:3000/posts?page=1

HTTP/1.1 200 OK
ETag: W/"7a6d57b4a84fa1754e8c9af6d9a91633"

$ curl -i http://localhost:3000/posts?page=1 \
     -H 'If-None-Match: W/"7a6d57b4a84fa1754e8c9af6d9a91633"'

HTTP/1.1 304 Not Modified
ETag: W/"7a6d57b4a84fa1754e8c9af6d9a91633"

# Request for page 2, has a different ETag
$ curl -i http://localhost:3000/posts?page=2 \
       -H 'If-None-Match: W/"7a6d57b4a84fa1754e8c9af6d9a91633"'

HTTP/1.1 200 OK
ETag: W/"5dc844e63cc9d20dfaefd6732c37bade"
```

You can clear both these entries with the base key:

```ruby
Rails.cache.delete('posts/index')
```

### Caching with Headers

Sometimes your controller might return different data based on some headers.  For example, you might look for the `Authorization` header to determine if a user has access to a requested resource.  You can specify headers to include in the cache key by passing the `:headers` option to `ez_cache_action`:

```ruby
# app/controllers/posts_controller.rb

class PostsController < ApplicationController
  include EzCache
  ez_cache_action :index, 'posts/index', headers: [:authorization]
end
```

Now the server will return a different ETag based on the `Authorization` header sent in.

```bash
# Request for user 123
$ curl -i http://localhost:3000/posts \
       -H 'Authorization: Bearer 123'

HTTP/1.1 200 OK
ETag: W/"7a6d57b4a84fa1754e8c9af6d9a91633"

$ curl -i http://localhost:3000/posts \
       -H 'Authorization: Bearer 123'
       -H 'If-None-Match: W/"7a6d57b4a84fa1754e8c9af6d9a91633"'

HTTP/1.1 304 Not Modified
ETag: W/"7a6d57b4a84fa1754e8c9af6d9a91633"

# Request for user 456, has a different ETag
$ curl -i http://localhost:3000/posts?page=2 \
       -H 'Authorization: Bearer 456'
       -H 'If-None-Match: W/"7a6d57b4a84fa1754e8c9af6d9a91633"'

HTTP/1.1 200 OK
ETag: W/"5dc844e63cc9d20dfaefd6732c37bade"
```

You can clear both these entries with the base key:

```ruby
Rails.cache.delete('posts/index')
```

### Caching with Parameterized Keys

Sometimes you want to

In your controller:

```ruby
# app/controllers/posts_controller.rb

class PostsController < ApplicationController
  include EzCache
  ez_cache_action :show, 'posts/show/:id'

  def show
    render json: Post.find(params[:id])
  end
end
```

```bash
# Request for post 123
$ curl -i http://localhost:3000/posts/123

HTTP/1.1 200 OK
ETag: W/"7a6d57b4a84fa1754e8c9af6d9a91633"

$ curl -i http://localhost:3000/posts/123 \
       -H 'If-None-Match: W/"7a6d57b4a84fa1754e8c9af6d9a91633"'

HTTP/1.1 304 Not Modified
ETag: W/"7a6d57b4a84fa1754e8c9af6d9a91633"

# Request for post 456, has a different ETag
$ curl -i http://localhost:3000/456 \
       -H 'If-None-Match: W/"7a6d57b4a84fa1754e8c9af6d9a91633"'

HTTP/1.1 200 OK
ETag: W/"5dc844e63cc9d20dfaefd6732c37bade"
```

Use the `:key` param specified to clear all caches for that action:

```ruby
Rails.cache.clear("posts/show/123") # Clear cache for just post 123
Rails.cache.clear("posts/show/456") # Clear cache for just post 456
```

## Contributing

- Fork the repo
- Make a branch
- Open a pull request against this repo

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
