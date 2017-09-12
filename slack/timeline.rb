module Slack
  class Timeline
    TYPING_SIGNAL_INTERVAL = 2.0

    def initialize(client, channel, channel_name, offset = 0.0)
      @client = client
      @channel = channel
      @channel_name = channel_name
      @current_time = offset
      start_timer
    end

    def type_message(text: '', typing_seconds: 0.0)
      schedule_typing(typing_seconds)
      schedule_message(text, typing_seconds)

      return self
    end

    def then(delay = 0.1, &block)
      advance_current_time(delay)
      info "Run block in #{@current_time} seconds"
      EventMachine.add_timer(@current_time, block)

      return self
    end

    def say_now(text)
      say(text)

      return self
    end

    def wait(delay = 0.0)
      advance_current_time(delay)
      info "Wait for #{@current_time} seconds"

      return self
    end

    private

    attr_accessor :client, :channel, :channel_name

    def advance_current_time(seconds)
      @current_time += seconds
      resume_timer if @current_time > 0.0
    end

    def consume_current_time(seconds)
      @current_time -= seconds

      if @current_time <= 0.0
        @current_time = 0.0
        info "Timeline is zero, cancelling the timer"
        @timer.cancel
      end
    end

    def start_timer
      @timer = EventMachine::PeriodicTimer.new(0.1) do consume_current_time(0.1) end
    end

    def resume_timer
      return unless @timer.instance_variable_get(:@cancelled)

      info "Timeline is non-zero, resuming the timer"
      @timer.instance_variable_set(:@cancelled, false)
      @timer.schedule
    end

    def schedule_typing(seconds)
      info "Scheduling typing signal in #{@current_time} seconds"
      EventMachine.add_timer(@current_time) do type end

      (seconds / TYPING_SIGNAL_INTERVAL).to_i.times do
        advance_current_time(TYPING_SIGNAL_INTERVAL)
        info "Scheduling typing signal in #{@current_time} seconds"
        EventMachine.add_timer(@current_time) do type end
      end
    end

    def schedule_message(message, seconds)
      advance_current_time(seconds % TYPING_SIGNAL_INTERVAL)

      info "Scheduling message \"#{message}\" in #{@current_time} seconds"
      EventMachine.add_timer(@current_time) do
        say(message)
      end
    end

    def say(text)
      info "Saying \"#{text}\""
      client.message channel: channel, text: text
    end

    def type
      info "Signal typing..."
      client.typing channel: channel
    end

    def info(log)
      Slack.config.logger.info "[#{channel_name}] " + log
    end
  end
end
