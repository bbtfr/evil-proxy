class HTTPClient
  class << self
    def get(url, proxy)
      RestClient::Request.execute(method: :get, url: url, proxy: proxy,
                                  verify_ssl: OpenSSL::SSL::VERIFY_NONE)
    end

    def head(url, proxy)
      RestClient::Request.execute(method: :head, url: url, proxy: proxy,
                                  verify_ssl: OpenSSL::SSL::VERIFY_NONE)
    end

    def post(url, payload, proxy)
      RestClient::Request.execute(method: :post, url: url, payload: payload,
                                  proxy: proxy, verify_ssl: OpenSSL::SSL::VERIFY_NONE)
    end

    def put(url, payload, proxy)
      RestClient::Request.execute(method: :put, url: url, payload: payload,
                                  proxy: proxy, verify_ssl: OpenSSL::SSL::VERIFY_NONE)
    end

    def patch(url, payload, proxy)
      RestClient::Request.execute(method: :patch, url: url, payload: payload,
                                  proxy: proxy, verify_ssl: OpenSSL::SSL::VERIFY_NONE)
    end

    def delete(url, proxy)
      RestClient::Request.execute(method: :delete, url: url, proxy: proxy,
                                  verify_ssl: OpenSSL::SSL::VERIFY_NONE)
    end
  end
end
