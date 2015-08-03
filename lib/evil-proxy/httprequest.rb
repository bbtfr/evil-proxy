WEBrick::HTTPRequest.class_eval do
  alias_method :original_body, :body
  def body
    @evil_body || original_body
  end

  def body= body
    @evil_body = body
  end

end
