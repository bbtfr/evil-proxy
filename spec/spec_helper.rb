require 'rest-client'
require 'json'

require 'evil-proxy'
require 'evil-proxy/async'

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

RSpec.configure do |config|
  config.order = 'random'
end
