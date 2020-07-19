require 'bundler/setup'
require 'faye/websocket'
require 'eventmachine'
require 'permessage_deflate'

EM.run {
  url   = ARGV[0]
  proxy = ARGV[1]
  ca    = File.expand_path('../../spec/server.crt', __FILE__)

  ws = Faye::WebSocket::Client.new(url, [],
    :proxy      => { :origin => proxy, :headers => { 'User-Agent' => 'Echo' } },
    :tls        => { :cert_authority_file => ca },
    :headers    => { 'Origin' => 'http://faye.jcoglan.com' },
    :extensions => [PermessageDeflate]
  )

  ws.onopen = lambda do |event|
    p [:open, ws.headers]
    ws.send('mic check')
  end

  ws.onclose = lambda do |close|
    p [:close, close.code, close.reason]
    EM.stop
  end

  ws.onerror = lambda do |error|
    p [:error, error.message]
  end

  ws.onmessage = lambda do |message|
    p [:message, message.data]
  end
}
