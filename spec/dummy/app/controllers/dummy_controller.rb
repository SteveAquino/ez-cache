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
end
