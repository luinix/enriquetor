module Slack
  class Channel
    MAX_PROBABILITY = 100
    MIN_PROBABILITY =   0
    MAX_PENDING_REPLIES = 1

    def initialize(client, channel, replier = Enriquetor, probability = 0)
      @probability = probability
      @talking = false
      @client = client
      @replier = replier
      @channel = channel
      @queue = []
      @timeline = Timeline.new(client, @channel, channel_name)
    end

    def process(message)
      return if message.user == client.self.id
      info "RECEIVED MESSAGE \"#{message.text}\""

      case message.text
      when /<@#{client.self.id}> shut up/ then
        decrease_probability
      when /<@#{client.self.id}> you are talking too little/ then
        increase_probability
      when /software/ then
        reply(["<@#{message.user}>", "shoftware can chave livesh", "for chure"].shuffle.join(', '))
      when /<@#{client.self.id}>/
        reply_bullshit(message)
      else
        if rand(MAX_PROBABILITY) < probability
          timeline.wait(1.0)
          reply_bullshit(message) 
        end
      end
    end

    private

    attr_accessor :timeline, :probability, :client, :replier, :channel, :logger

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

    def reply_bullshit(message)
      return add_to_queue(message) if @talking

      @talking = true
      info "Scheduling talk..."
      replier.message("<@#{message.user}>").each do |reply|
        timeline.type_message(reply)
      end

      timeline.then do
        @talking = false
        info "Done!"
        reply_bullshit(@queue.pop) if @queue.length > 0
      end

      info "Scheduling finished"
    end

    def reply(text)
      Typer.add_typing(text).each do |reply| timeline.type_message(reply) end
    end

    def info(log)
      Slack.config.logger.info "[#{channel_name}] " + log
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
  end
end
