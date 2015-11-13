require 'webrick/httprequest'

WEBrick::HTTPRequest.class_eval do
  attr_writer :body, :unparsed_uri
end
