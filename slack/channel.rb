module Slack
  class Channel
    MAX_PROBABILITY = 100
    MIN_PROBABILITY =   0

    def initialize(client, channel, replier = Enriquetor, probability = 10)
      @probability = probability
      @client = client
      @replier = replier
      @channel = channel
    end

    def process(message)
      case message.text
      when /<@#{client.self.id}> shut up/ then
        decrease_probability
        say "for chure, lowering probability to #{probability} out of #{MAX_PROBABILITY}"
      when /<@#{client.self.id}> you are talking too little/ then
        increase_probability
        say "for chure, increasing probability to #{probability} out of #{MAX_PROBABILITY}"
      when /<@#{client.self.id}>/
        reply(message)
      else
        reply(message) if rand(MAX_PROBABILITY) < probability
      end
    end

    private

    attr_accessor :probability, :client, :replier, :channel

    def increase_probability(increment = 10)
      @probability += increment
      @probability = MAX_PROBABILITY if probability > MAX_PROBABILITY
    end

    def decrease_probability(increment = 10)
      @probability -= increment
      @probability = MIN_PROBABILITY if probability < MIN_PROBABILITY
    end

    def reply(data)
      replier.message("<@#{data.user}>").inject(1.0) do |timeline, message|
        typing_millis = message[:typing_millis]

        (typing_millis / 1000).times do
          EventMachine.add_timer(timeline) do type end
          timeline += 1
        end

        timeline = timeline + ((typing_millis % 1000) / 1000.0)
        EventMachine.add_timer(timeline) do
          say(message[:text])
        end

        timeline
      end
    end

    def say(text)
      client.message channel: channel, text: text
    end

    def type
      client.typing channel: channel
    end
  end
end
