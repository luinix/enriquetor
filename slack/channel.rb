module Slack
  class Channel
    MAX_PROBABILITY = 100
    MIN_PROBABILITY =   0
    MAX_PENDING_REPLIES = 2

    def initialize(client, channel, replier = Enriquetor, probability = 10)
      @probability = probability
      @talking = false
      @client = client
      @replier = replier
      @channel = channel
      @queue = []
      @timeline = Timeline.new(client, @channel)
    end

    def process(message)
      case message.text
      when /<@#{client.self.id}> shut up/ then
        decrease_probability
      when /<@#{client.self.id}> you are talking too little/ then
        increase_probability
      when /<@#{client.self.id}>/
        timeline.wait(1.0)
        reply(message)
      else
        timeline.wait(1.0)
        reply(message) if rand(MAX_PROBABILITY) < probability
      end
    end

    private

    attr_accessor :timeline, :probability, :client, :replier, :channel, :logger

    def increase_probability(increment = 10)
      @probability += increment
      @probability = MAX_PROBABILITY if probability > MAX_PROBABILITY
      timeline.say_now "for chure, increasing probability to #{probability} out of #{MAX_PROBABILITY}"
    end

    def decrease_probability(increment = 10)
      @probability -= increment
      @probability = MIN_PROBABILITY if probability < MIN_PROBABILITY
      timeline.say_now "for chure, lowering probability to #{probability} out of #{MAX_PROBABILITY}"
    end

    def add_to_queue(data)
      @queue.unshift(data)
      @queue.pop if @queue.length > MAX_PENDING_REPLIES
    end

    def reply(data)
      return add_to_queue(data) if @talking

      @talking = true
      replier.message("<@#{data.user}>").each do |message|
        timeline.type_message(message)
      end

      timeline.then do
        @talking = false
        reply(@queue.pop) if @queue.length > 0
      end
    end
  end
end
