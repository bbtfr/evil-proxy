EvilProxy::HTTPProxyServer.class_eval do
  attr_reader :thread
  alias_method :original_start, :start
  alias_method :original_shutdown, :shutdown

  def start
    @thread = Thread.new do
      self.original_start
    end
  end

  def shutdown
    @thread.exit
  end

  def join
    @thread.join
  end
end
