PROXY.send :initialize_callbacks, {}

# PROXY.before_response do |req, res|
#   puts "#{req.request_method} #{req.request_uri || req.unparsed_uri}".colorize(:blue)
# end

PROXY.before_request do |req|
  puts "#{req.request_method} #{req.request_uri || req.unparsed_uri}".colorize(:blue)
end
