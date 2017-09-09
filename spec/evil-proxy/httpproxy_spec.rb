require 'spec_helper'

describe EvilProxy::HTTPProxyServer do
  before :all do
    @server = EvilProxy::MITMProxyServer.new Port: 3128, Quiet: true
    @server.start
  end

  after :all do
    @server.shutdown
  end

  let(:proxy) { 'http://127.0.0.1:3128' }

  it 'proxy GET requests' do
    content = HTTPClient.get('http://httpbin.org/get', proxy)

    expect(content).not_to be_nil
  end

  it 'proxy HEAD requests' do
    content = HTTPClient.head('https://httpbin.org/get', proxy)

    expect(content).not_to be_nil
  end

  it 'proxy POST requests' do
    content = HTTPClient.post('https://httpbin.org/post', { param: 'value' }, proxy)

    expect(content).not_to be_nil

    json = JSON.parse(content)

    expect(json['form']['param']).to eq('value')
  end

  it 'proxy PUT requests' do
    content = HTTPClient.put('https://httpbin.org/put', { param: 'value' }, proxy)

    expect(content).not_to be_nil

    json = JSON.parse(content)

    expect(json['form']['param']).to eq('value')
  end

  it 'proxy PATCH requests' do
    content = HTTPClient.patch('https://httpbin.org/patch', { param: 'value' }, proxy)

    expect(content).not_to be_nil

    json = JSON.parse(content)

    expect(json['form']['param']).to eq('value')
  end

  it 'proxy DELETE requests' do
    content = HTTPClient.delete('https://httpbin.org/delete', proxy)

    expect(content).not_to be_nil
  end
end
