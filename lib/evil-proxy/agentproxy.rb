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

  def perform_proxy_request(req, res, req_class, body_stream = nil)
    uri = req.request_uri
    path = uri.path.dup
    path << "?" << uri.query if uri.query
    header = setup_proxy_header(req, res)
    upstream = setup_upstream_proxy_authentication(req, res, header)

    body_tmp = []
    http = Net::HTTP.new(uri.host, uri.port, upstream.host, upstream.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req_fib = Fiber.new do
      http.start do
        if @config[:ProxyTimeout]
          ##################################   these issues are
          http.open_timeout = 30   # secs  #   necessary (maybe because
          http.read_timeout = 60   # secs  #   Ruby's bug, but why?)
          ##################################
        end
        if body_stream && req['transfer-encoding'] =~ /\bchunked\b/i
          header['Transfer-Encoding'] = 'chunked'
        end
        http_req = req_class.new(path, header)
        http_req.body_stream = body_stream if body_stream
        http.request(http_req) do |response|
          # Persistent connection requirements are mysterious for me.
          # So I will close the connection in every response.
          res['proxy-connection'] = "close"
          res['connection'] = "close"

          # stream Net::HTTP::HTTPResponse to WEBrick::HTTPResponse
          res.status = response.code.to_i
          res.chunked = response.chunked?
          choose_header(response, res)
          set_cookie(response, res)
          set_via(res)
          response.read_body do |buf|
            body_tmp << buf
            Fiber.yield # wait for res.body Proc#call
          end
        end # http.request
      end
    end
    req_fib.resume # read HTTP response headers and first chunk of the body
    res.body = ->(socket) do
      while buf = body_tmp.shift
        socket.write(buf)
        buf.clear
        req_fib.resume # continue response.read_body
      end
    end
  end

  def service req, res
    fire :before_request, req
    proxy_service req, res
    fire :before_response, req, res
  end

end
