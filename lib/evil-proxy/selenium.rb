require 'evil-proxy/async'

EvilProxy::HTTPProxyServer.class_eval do
  def selenium_proxy *protocols
    require 'selenium-webdriver' unless defined?(Selenium)

    protocols.push :http if protocols.empty?
    unless (protocols - [:http, :ssl, :ftp]).empty?
      raise "Invalid protocol specified.  Must be one of: :http, :ssl, or :ftp."
    end

    host = @config[:BindAddress] || "127.0.0.1"
    port = @config[:Port]

    proxy_mapping = Hash.new
    protocols.each do |proto| proxy_mapping[proto] = "#{host}:#{port}" end
    Selenium::WebDriver::Proxy.new(proxy_mapping)
  end
end
