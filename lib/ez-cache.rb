module EzCache
  extend ActiveSupport::Concern

  module ClassMethods
    def ez_cache_action(options={})
      base_key      = options.delete(:key)
      cache_params  = options.delete(:params)  || {}
      cache_headers = options.delete(:headers) || {}

      before_action options do |controller|
        etag = [
          delta_cache_key(base_key),
          params_cache_key(cache_params),
          header_cache_key(cache_headers)
        ]

        controller.fresh_when etag: etag.join('/')
      end
    end
  end

  def delta_cache_key(base_key)
    Rails.cache.fetch(base_key) { SecureRandom.base64(10) }
  end

  def params_cache_key(cache_params)
    params.permit(cache_params).to_h.to_s
  end

  def header_cache_key(cache_headers)
    cache_headers.inject({}) do |hash, key|
      return hash unless request.headers.include?(key)
      hash.merge key => request.headers.fetch(key)
    end.to_s
  end
end
