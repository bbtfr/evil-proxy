# EvilProxy

A ruby http/https proxy, with SSL MITM support to do :imp: things.

## Installation

Add this line to your application's Gemfile:

    gem 'evil-proxy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install evil-proxy

## Usage

#### MITMProxyServer
`MITMProxyServer` is a subclass of `HTTPProxyServer`, so it also has the callback & plugin system, this proxy will embed a mini CA, which generates certificates on the fly, so you may need to import the CA certificate (./certs/CA/cacert.pem) into your browser.

```ruby
require 'evil-proxy'

proxy = EvilProxy::MITMProxyServer.new Port: 8080
proxy.start
```

Without import the CA certificate
```shell
$ https_proxy=http://localhost:8080 curl https://github.com
# =>
# curl: (60) SSL certificate problem: Invalid certificate chain
# More details here: http://curl.haxx.se/docs/sslcerts.html
# 
# curl performs SSL certificate verification by default, using a "bundle"
#  of Certificate Authority (CA) public keys (CA certs). If the default
#  bundle file isn't adequate, you can specify an alternate file
#  using the --cacert option.
# If this HTTPS server uses a certificate signed by a CA represented in
#  the bundle, the certificate verification probably failed due to a
#  problem with the certificate (it might be expired, or the name might
#  not match the domain name in the URL).
# If you'd like to turn off curl's verification of the certificate, use
#  the -k (or --insecure) option.
```

```shell
$ https_proxy=http://localhost:8080 curl https://github.com --insecure
# =>
# <!DOCTYPE html>
# <html lang="en" class="">
# ...
```

So you can intercept and modify https traffic, ie: requests & responses.

#### Basic usage: hooks

```ruby
require 'evil-proxy'

# EvilProxy::HTTPProxyServer is a subclass of Webrick::HTTPProxyServer;
#   it takes the same parameters.
proxy = EvilProxy::HTTPProxyServer.new Port: 8080

proxy.before_request do |req|
  # Do evil things
  # Note that, different from Webrick::HTTPProxyServer, 
  #   `req.body` is writable.
end

proxy.before_response do |req, res|
  # Here `res.body` is also writable.
end

trap "INT"  do proxy.shutdown end
trap "TERM" do proxy.shutdown end

proxy.start
```

Available hooks including `when_initialize`, `when_start`, `when_shutdown`, 
  `before_request`, `before_response`, `(before|after)_(get|head|post|options|connect)`.

#### Plugin: store
  
If you want to save the network traffic, you can use `store` plugin,
  network traffic will be saved in `store.yml`.
```ruby
require 'evil-proxy'
require 'evil-proxy/store'

proxy = EvilProxy::HTTPProxyServer.new Port: 8080

proxy.store_filter do |req, res|
  # Optional, if you don't set `store_filter`, evil-proxy
  #   will save all the network traffic.
  res.unparsed_uri =~ /www.google.com/
end

...
```

#### Plugin: async
Start the proxy server asnychronously, which means start server in a background thread;
with it, you can check the `store` when runing the proxy server.
```ruby
require 'evil-proxy'
require 'evil-proxy/async'
require 'evil-proxy/store'
require 'yaml'

proxy = EvilProxy::HTTPProxyServer.new Port: 8080

proxy.start

loop do
  # Do something with `proxy.store`
  puts proxy.store.to_yaml
  proxy.clean_store # if needed
  sleep 10
end

...
```

#### Plugin: selenium
Use `proxy.selenium_proxy` to create a instance of `Selenium::WebDriver::Proxy`.

```ruby
require 'evil-proxy'
require 'evil-proxy/selenium'
require 'selenium/webdriver'

proxy = EvilProxy::HTTPProxyServer.new Port: 8080
proxy.start

driver = Selenium::WebDriver.for :chrome, proxy: proxy.selenium_proxy

...
```


## Contributing

1. Fork it ( https://github.com/bbtfr/evil-proxy/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
