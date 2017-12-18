class RequestController
  attr_reader :tcp_server,
              :cycles,
              :close_server

  def initialize
    @tcp_server = TCPServer.new(9292)
    @cycles = 0
    @close_server = false
  end

  def open_server
    loop do
    @client = tcp_server.accept
    puts "Ready for a request"
    request_lines = []
      while line = @client.gets and !line.chomp.empty?
        request_lines << line.chomp
      end
    puts "Got this request:"
    output  = "<html><head></head><body>Hello World(#{cycles})</body></html>"
    headers = ["http/1.1 200 ok",
      "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
      "server: ruby",
      "content-type: text/html; charset=iso-8859-1",
      "content-length: #{output.length}\r\n\r\n"].join("\r\n")
    # puts request_lines.inspect
    # puts headers
    @client.puts headers
    @client.puts output
    puts "Sending response."
    verb, path, protocol = request_lines.first.split(" ")
      if path.scan("?").any?
        path, params = path.split("?")
        response = "<pre>" + "verb: " + verb + " params: " + params + " path: " + path + " protocol: " + protocol + "\n\n"+ request_lines.join("\n") + "</pre>"
      else
        response = "<pre>" + "verb: " + verb + " path: " + path + " protocol: " + protocol + "\n\n"+ request_lines.join("\n") + "</pre>"
      end
      @cycles += 1
    end
    @client.close_server = true
  end

  def close_server
    tcp_server.close
  end

end
