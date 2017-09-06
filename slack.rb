require_relative 'enriquetor'
require 'slack-ruby-client'

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
  config.logger = Logger.new(STDOUT)
  config.logger.level = Logger::INFO
  fail 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
end

def reply(client, data)
  Enriquetor.message("<@#{data.user}>").inject(1.0) do |timeline, message|
    typing_millis = message[:typing_millis]

    (typing_millis / 1000).times do
      EventMachine.add_timer(timeline) do
        client.typing channel: data.channel
      end
      timeline += 1
    end

    timeline = timeline + ((typing_millis % 1000) / 1000.0)
    EventMachine.add_timer(timeline) do
      client.message channel: data.channel, text: message[:text]
    end

    timeline
  end
end

$stdout.sync = true
logger = Logger.new($stdout)
logger.level = Logger::DEBUG

client = Slack::RealTime::Client.new
probability = 10

client.on :hello do
  logger.info "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
end

client.on :message do |data|
  logger.info data

  case data.text
  when /<@#{client.self.id}> shut up/ then
    probability -= 10
    probability = 0 if probability < 0
    client.message channel: data.channel, text: "Lowering probability to #{probability} out of 100"
  when /<@#{client.self.id}> you are talking too little/ then
    probability += 10
    client.message channel: data.channel, text: "Increasing probability to #{probability} out of 100"
  when /<@#{client.self.id}>/
    reply(client, data)
  else
    reply(client, data) if rand(100) < probability
  end
end

client.start_async

loop do
  Thread.pass
end
