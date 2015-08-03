require 'yaml'

EvilProxy::HTTPProxyServer.class_eval do
  attr_reader :store

  when_initialize do
    clean_store
  end

  when_shutdown do
    dump_store
  end

  before_response do |req, res|
    @store << [ req, res ] if match_store_filter req, res
  end

  def store_filter &block
    @store_filter = block
  end

  def match_store_filter req, res
    return true unless @store_filter
    instance_exec req, res, &@store_filter
  end

  def clean_store
    @store = []
  end

  def dump_store filename = "store.yml"
    previous_store = YAML.load(File.read(filename)) || [] rescue []
    File.open filename, "w" do |file|
      file.puts YAML.dump(previous_store + store_as_params)
    end
    clean_store
  end

  def store_as_params
    @store.map do |req, res|
      Hash.new.tap do |params|
        params["request"] = Hash.new.tap do |request|
          request["method"] = req.request_method
          request["url"] = req.unparsed_uri
          request["headers"] = Hash.new.tap do |headers|
            req.header.each do |key, value|
              headers[key] = value.join(",")
            end
          end
          request["body"] = req.body if req.body
          request["time"] = req.request_time
        end
        params["response"] = Hash.new.tap do |response|
          response["headers"] = res.header
          response["body"] = res.body if req.body
          response["status"] = res.status
        end
      end
    end
  end
end
