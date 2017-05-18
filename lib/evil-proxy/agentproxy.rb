require 'webrick'
require 'webrick/https'
require 'webrick/httpproxy'
require 'openssl'

class EvilProxy::AgentProxyServer < EvilProxy::HTTPProxyServer

  def initialize_callbacks config
    @mitm_server = config[:MITMProxyServer]
  end

  def fire key, *args
    @mitm_server.fire key, *args, self
  end

  def perform_proxy_request(req, res)
    uri = req.request_uri
    path = uri.path.dup
    path << "?" << uri.query if uri.query
    header = Hash.new
    choose_header(req, header)
    response = nil

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.start do
      if @config[:ProxyTimeout]
        ##################################   these issues are
        http.open_timeout = 30   # secs  #   necessary (maybe because
        http.read_timeout = 60   # secs  #   Ruby's bug, but why?)
        ##################################
      end

      response = yield(http, path, header)
    end

    # Persistent connection requirements are mysterious for me.
    # So I will close the connection in every response.
    res['proxy-connection'] = "close"
    res['connection'] = "close"

    # Convert Net::HTTP::HTTPResponse to WEBrick::HTTPResponse
    res.status = response.code.to_i
    choose_header(response, res)
    set_cookie(response, res)
    res.body = response.body
  end

  def service req, res
    fire :before_request, req
    proxy_service req, res
    fire :before_response, req, res
  end

end
