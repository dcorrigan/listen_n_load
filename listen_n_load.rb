require 'socket'

class ListenNLoad
  def initialize(port)
    @server = TCPServer.new(port)
  end

  def start
    Thread.new do
      puts 'Listening for files to reload ...'
      loop do
        Thread.start(@server.accept) do |client|
          watch(client)
        end
      end
    end
  end

  private

  def watch(client)
    file = client.gets.chomp
    load_file(file)
    client.close
  end

  def load_file(file)
    if !file.nil? && File.exist?(file)
      guarded_load(file)
    else
      puts "#{file.blank? ? '[NULL]' : file} does not exist!"
    end
  end

  def guarded_load(file)
    load file
  rescue StandardError => err
    handle_error(file, err)
  end

  def handle_error(file, err)
    puts "Failed to load #{file}!"
    raise err
  end
end

lnl = ListenNLoad.new(ENV['LNL_PORT'] || 2222)
lnl.start
