# Evil::Proxy

A ruby http proxy to do EVIL things.

## Installation

Add this line to your application's Gemfile:

    gem 'evil-proxy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install evil-proxy

## Usage

```ruby
# EvilProxy::HTTPProxyServer is a subclass of Webrick::HTTPProxyServer
# it takes the same parameters
proxy = EvilProxy::HTTPProxyServer.new Port: 8080

```

## Contributing

1. Fork it ( https://github.com/bbtfr/evil-proxy/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
