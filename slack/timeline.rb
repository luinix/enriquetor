module Slack
  class Timeline
    def initialize(client, channel, channel_name, offset = 0.0)
      @client = client
      @channel = channel
      @channel_name = channel_name
      @current_time = offset

      EventMachine.add_periodic_timer(0.1) do
        @current_time -= 0.1
        @current_time = 0.0 if @current_time < 0.0
      end
    end

    def type_message(message)
      typing_millis = message[:typing_millis]

      info "Send typing in #{@current_time} seconds"
      EventMachine.add_timer(@current_time) do type end
      (typing_millis / 2000).times do
        @current_time += 2.0
        info "Send typing in #{@current_time} seconds"
        EventMachine.add_timer(@current_time) do type end
      end

      @current_time += ((typing_millis % 2000) / 1000.0)
      info "Send #{message[:text]} in #{@current_time} seconds"
      EventMachine.add_timer(@current_time) do
        say(message[:text])
      end

      return self
    end

    def then(delay = 0.0, &block)
      @current_time += delay
      info "Run block in #{@current_time} seconds"
      EventMachine.add_timer(@current_time, block)
    end

    def say_now(text)
      say(text)
    end

    def wait(seconds = 0.0)
      @current_time += seconds
      info "Wait for #{@current_time} seconds"
    end

    private

    attr_accessor :client, :channel, :channel_name

    def say(text)
      info "Saying #{text}"
      client.message channel: channel, text: text
    end

    def type
      info "Typing"
      client.typing channel: channel
    end

    def info(log)
      Slack.config.logger.info "[#{channel_name}] " + log
    end
  end
end
