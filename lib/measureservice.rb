require 'em-proxy'
require 'http/parser'
require 'uuid'
require './lib/measureserviceplayer'

class MeasureService
  def run
    puts "Starting Measure Service"
    Proxy.start(:host => "0.0.0.0", :port => 8888) do |conn|
      @p = Http::Parser.new
      @p.on_headers_complete = proc do |h|
        session = UUID.generate
        # puts "Starting new session: #{session}"
        # puts h.inspect

        host, port = h['Host'].split(':')
        conn.server session, :host => host, :port => (port || 80)
        conn.relay_to_servers @buffer

        @buffer.clear
        msp = MeasureServicePlayer.new(h)
        if msp.is_playing then
          provider = msp.provider.name
          type = msp.provider.type
          time = Time.now
          puts "#{time} Video is playing from #{provider} (#{type})"
        end
      end
      @buffer = ''
        
      conn.on_connect do |data,b|
        # puts [:on_connect, data, b].inspect
      end

      conn.on_data do |data|
        @buffer << data
        @p << data

        data
      end

      conn.on_response do |backend, resp|
        # puts [:on_response, backend, resp].inspect
        resp
      end

      conn.on_finish do |backend, name|
        # puts [:on_finish, name].inspect
      end
    end
  end

end
