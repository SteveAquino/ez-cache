module EzCache
  extend ActiveSupport::Concern

  module ClassMethods
    def ez_cache_action(action, base_key, options={})
      cache_params  = options[:params]  || {}
      cache_headers = options[:headers] || {}

      # Convert action name to to array to
      # ensure caching is opt-in only
      action = action.kind_of?(Array) ? action : [action]

      before_action only: action do |controller|
        etag = [
          delta_cache_key(base_key, params),
          params_cache_key(cache_params),
          header_cache_key(cache_headers)
        ]

        controller.fresh_when etag: etag.join('/')
      end
    end
  end

  def delta_cache_key(_base_key, params={})
    base_key = _base_key.dup
    base_key.scan(/:[\w\_]+/).each do |match|
      key   = match.gsub(/\A:/, '')
      value = params.permit(key)[key]
      base_key.gsub! match, value.to_s
    end

    Rails.cache.fetch(base_key) { SecureRandom.base64(10) }
  end

  def params_cache_key(cache_params)
    params.permit(cache_params).to_h.to_s
  end

  def header_cache_key(cache_headers)
    cache_headers.inject({}) do |hash, key|
      return hash unless request.headers.include?(key)
      hash.merge key.to_s => request.headers.fetch(key)
    end.to_s
  end
end
