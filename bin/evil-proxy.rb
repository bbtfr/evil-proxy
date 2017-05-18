PROXY.restart do
  # @mitm_pattern = /partten/
end

# PROXY.before_response do |req, res|
#   puts "#{req.request_method} #{req.request_uri || req.unparsed_uri}".colorize(:blue)
# end

PROXY.before_response do |req, res|
  if req.unparsed_uri.start_with? 'http://101.251.217.210' or req.unparsed_uri.start_with? 'http://api.gifshow.com'
    puts "#{req.request_method} #{req.request_uri || req.unparsed_uri}".colorize(:blue)
    puts req.header
    puts req.body.colorize(:green)
    puts res.body.colorize(:red)
  else
    puts "#{req.request_method} #{req.request_uri || req.unparsed_uri}"
  end
end
