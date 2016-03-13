class DummyController < ApplicationController
  include EzCache

  ez_cache_action :index, 'dummmy/index', params: [:page]

  ez_cache_action :protected, 'dummmy/protected', headers: [:authorization]

  ez_cache_action :show, 'dummmy/show/:id'

  # Returns the current time
  def index
    render json: {time: Time.now}
  end

  # Returns the given id
  def show
    render json: {id: params.permit(:id)[:id]}
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
