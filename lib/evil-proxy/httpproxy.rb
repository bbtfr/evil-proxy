require 'webrick'
require 'webrick/httpproxy'

class EvilProxy::HTTPProxyServer < WEBrick::HTTPProxyServer
  VALID_CALBACKS = Array.new
  DEFAULT_CALLBACKS = Hash.new

  def initialize *args
    initialize_callbacks
    fire :when_initialize, *args
    super
  end

  def start
    fire :when_start
    super
  end

  def shutdown
    fire :when_shutdown
    super
  end

  def fire key, *args
    return unless @callbacks[key]
    @callbacks[key].each do |callback|
      instance_exec *args, &callback
    end
  end

  def proxy_service req, res
    fire :before_request, req
    super
    fire :before_response, req, res
  end

  VALID_CALBACKS << :when_initialize
  VALID_CALBACKS << :when_start
  VALID_CALBACKS << :when_shutdown
  VALID_CALBACKS << :before_request
  VALID_CALBACKS << :before_response

  %w(GET HEAD POST OPTIONS CONNECT).each do |method|
    do_method = "do_#{method}".to_sym
    do_method_without_callbacks = "#{do_method}_without_callbacks".to_sym
    before_method = "before_#{method.downcase}".to_sym
    after_method = "after_#{method.downcase}".to_sym

    VALID_CALBACKS << before_method
    VALID_CALBACKS << after_method

    alias_method do_method_without_callbacks, do_method
    define_method do_method do |req, res|
      fire before_method, req
      send do_method_without_callbacks, req, res
      fire after_method, req, res
    end
  end

  VALID_CALBACKS.each do |callback|
    define_method callback do |&block|
      @callbacks[callback] ||= []
      @callbacks[callback] << block
    end
  end

private
  def initialize_callbacks
    @callbacks = Hash.new
    DEFAULT_CALLBACKS.each do |key, callbacks|
      @callbacks[key] = callbacks.clone
    end
  end

  class << self
    VALID_CALBACKS.each do |callback|
      define_method callback do |&block|
        DEFAULT_CALLBACKS[callback] ||= []
        DEFAULT_CALLBACKS[callback] << block
      end
    end
  end

end
