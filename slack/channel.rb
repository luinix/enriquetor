module Slack
  class Channel
    MAX_PROBABILITY = 100
    MIN_PROBABILITY =   0
    MAX_PENDING_REPLIES = 1

    def initialize(client, channel, replier = Enriquetor)
      @probability = ENV['DEFAULT_PROBABILITY'].to_i || 0
      @talking = false
      @client = client
      @api_client = Slack::Web::Client.new
      @replier = replier
      @channel = channel
      @queue = []
      @timeline = Timeline.new(client, @channel, channel_name)
    end

    def process(received_message)
      return if received_message.user == client.self.id
      info "RECEIVED MESSAGE: \"#{received_message.text}\"", received_message.user

      case received_message.text
      when /<@#{client.self.id}> shut up/ then
        decrease_probability
      when /<@#{client.self.id}> you are talking too little/ then
        increase_probability
      when /software/i then
        reply_now(["<@#{received_message.user}>", "shoftware can chave livesh", "for chure"].shuffle.join(', '))
      when /<@#{client.self.id}>/
        reply_in_order(received_message)
      else
        if rand(MAX_PROBABILITY) < probability && received_message.user
          timeline.wait(1.0)
          reply_in_order(received_message) 
        end
      end
    end

    private

    attr_accessor :timeline, :probability, :client, :api_client, :replier, :channel, :logger

    def increase_probability(increment = 5)
      @probability += increment
      @probability = MAX_PROBABILITY if probability > MAX_PROBABILITY
      timeline.say_now "for chure, increasing probability to #{probability} out of #{MAX_PROBABILITY}"
    end

    def decrease_probability(increment = 5)
      @probability -= increment
      @probability = MIN_PROBABILITY if probability < MIN_PROBABILITY
      timeline.say_now "for chure, lowering probability to #{probability} out of #{MAX_PROBABILITY}"
    end

    def add_to_queue(message)
      info "Adding message to queue because we're still typing the previous one"
      @queue.unshift(message)
      if @queue.length > MAX_PENDING_REPLIES
        info "Full queue: removing oldest message from the queue, will not reply to it"
        @queue.pop
      end
    end

    def reply_in_order(received_message)
      return add_to_queue(received_message) if @talking

      @talking = true
      info "Scheduling talk..."
      replier.get_reply(user(received_message.user)).each do |reply|
        timeline.type_message(reply)
      end

      timeline.then do
        @talking = false
        info "Done!"
        reply_in_order(@queue.pop) if @queue.length > 0
      end

      info "Scheduling finished"
    end

    def reply_now(text)
      Typer.add_typing(text).each do |reply| timeline.type_message(reply) end
    end

    def info(log, user_id = nil)
      prefix = "[#{channel_name}]"
      prefix += "[#{user(user_id).name}]" if user_id
      Slack.config.logger.info prefix + " " + log
    end

    def channel_name
      begin
      @channel_name ||= Slack::Web::Client.new.groups_info(channel: channel).group.name
      rescue Slack::Web::Api::Errors::SlackError
        begin
          @channel_name = '#' + Slack::Web::Client.new.channels_info(channel: channel).channel.name
        rescue Slack::Web::Api::Errors::SlackError
          @channel_name = "DirectMessage"
        end
      end
    end

    def user(user_id)
      users_cache[user_id]
    end

    def users_cache
      @users_cache ||= Hash.new do |users_cache, user_id|
        users_cache[user_id] = api_client.users_info(user: user_id).user
      end
    end
  end
end
