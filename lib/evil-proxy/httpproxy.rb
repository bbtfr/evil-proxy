require 'webrick'
require 'webrick/httpproxy'

class EvilProxy::HTTPProxyServer < WEBrick::HTTPProxyServer
  attr_reader :callbacks

  DEFAULT_CALLBACKS = Hash.new

  SUPPORTED_METHODS = %w(GET HEAD POST PUT PATCH DELETE OPTIONS CONNECT).freeze

  def initialize config = {}, default = WEBrick::Config::HTTP
    initialize_callbacks config
    fire :when_initialize, config, default
    config.merge!(
      Logger: WEBrick::Log.new(nil, 0),
      AccessLog: []
    ) if config[:Quiet]
    super
  end

  def start
    begin
      fire :when_start
      super
    ensure
      fire :when_shutdown
    end
  end

  def stop
    self.logger.info "#{self.class}#stop: pid=#{$$}"
    super
  end

  def exit
    self.logger.info "#{self.class}#exit: pid=#{$$}"
    Kernel.exit
  end

  def restart &block
    self.logger.info "#{self.class}#restart: pid=#{$$}" if @status == :Running
    initialize_callbacks Hash.new
    instance_exec &block if block
  end

  def fire key, *args
    return unless @callbacks[key]
    @callbacks[key].each do |callback|
      instance_exec *args, &callback
    end
  end

  def service req, res
    fire :before_request, req
    super
    fire :before_response, req, res
  end

  def self.define_callback_methods callback
    define_method callback do |&block|
      @callbacks[callback] ||= []
      @callbacks[callback] << block
    end

    define_singleton_method callback do |&block|
      DEFAULT_CALLBACKS[callback] ||= []
      DEFAULT_CALLBACKS[callback] << block
    end
  end

  def do_PUT(req, res)
    perform_proxy_request(req, res) do |http, path, header|
      http.put(path, req.body || '', header)
    end
  end

  def do_DELETE(req, res)
    perform_proxy_request(req, res) do |http, path, header|
      http.delete(path, header)
    end
  end

  def do_PATCH(req, res)
    perform_proxy_request(req, res) do |http, path, header|
      http.patch(path, req.body || '', header)
    end
  end

  def do_OPTIONS(req, res)
    perform_proxy_request(req, res) do |http, path, header|
      http.options(path, header)
    end
  end

  define_callback_methods :when_initialize
  define_callback_methods :when_start
  define_callback_methods :when_shutdown
  define_callback_methods :before_request
  define_callback_methods :before_response

  SUPPORTED_METHODS.each do |method|
    do_method = "do_#{method}".to_sym
    do_method_without_callbacks = "#{do_method}_without_callbacks".to_sym
    before_method = "before_#{method.downcase}".to_sym
    after_method = "after_#{method.downcase}".to_sym

    define_callback_methods before_method
    define_callback_methods after_method

    alias_method do_method_without_callbacks, do_method
    define_method do_method do |req, res|
      fire before_method, req
      send do_method_without_callbacks, req, res
      fire after_method, req, res
    end
  end

private
  def initialize_callbacks config
    @callbacks = Hash.new
    DEFAULT_CALLBACKS.each do |key, callbacks|
      @callbacks[key] = callbacks.clone
    end
  end
end
