require_relative 'enriquetor'
require 'slack-ruby-client'

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
  config.logger = Logger.new(STDOUT)
  config.logger.level = Logger::INFO
  fail 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
end

channels = {}

$stdout.sync = true
logger = Logger.new($stdout)
logger.level = Logger::DEBUG

client = Slack::RealTime::Client.new

client.on :message do |data|
  channels[data.channel] = channels[data.channel] || Slack::Channel.new(client, data.channel)
  channels[data.channel].process(data)
end

client.start_async

loop do
end
