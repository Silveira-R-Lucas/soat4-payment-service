class RabbitmqConnection
  require "bunny"
  def self.start
    tries ||= 5
    connection = Bunny.new(ENV.fetch("RABBITMQ_URL", "amqp://guest:guest@rabbitmq:5672"))
    connection.start
    connection
  rescue Bunny::TCPConnectionFailedForAllHosts, Bunny::NetworkFailure => e
    tries -= 1
    if tries > 0
      puts "⚠️  [RabbitMQ] Conexão falhou, tentando novamente em 5s (#{tries} tentativas restantes)..."
      sleep 5
      retry
    else
      raise e
    end
  end

  def self.channel
    @channel ||= start.create_channel
  end
end
