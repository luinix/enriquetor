module Slack
  class Timeline
    def initialize(client, channel, offset = 0.0)
      @client = client
      @channel = channel
      @current_time = offset

      EventMachine.add_periodic_timer(0.1) do
        @current_time -= 0.1
        @current_time = 0.0 if @current_time < 0.0
      end
    end

    def type_message(message)
      typing_millis = message[:typing_millis]

      (typing_millis / 1000).times do
        EventMachine.add_timer(@current_time) do type end
        @current_time += 1.0
      end

      @current_time += ((typing_millis % 1000) / 1000.0)
      EventMachine.add_timer(@current_time) do
        say(message[:text])
      end

      return self
    end

    def then(delay = 0.0, &block)
      @current_time += delay
      EventMachine.add_timer(@current_time, block)
    end

    def say_now(text)
      say(text)
    end

    def wait(seconds = 0.0)
      @current_time += seconds
    end

    private

    attr_accessor :client, :channel

    def say(text)
      client.message channel: channel, text: text
    end

    def type
      client.typing channel: channel
    end
  end
end
