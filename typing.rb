class Typing
  AVERAGE_LINE_LENGTH = 40
  CHARACTERS_PER_MINUTE = 400
  SPEED_VARIATION = 10 # ± 10%

  def self.simulate(message)
    self.new(message).format
  end

  def initialize(message)
    @message = message
    @breaks = Array.new(max_line_breaks, "\n")
  end

  def format
    add_line_breaks
    split_and_add_typing_time
  end

  private

  def split_and_add_typing_time
    @message.split("\n").map { |line|
      { text: line,
        typing_millis: (line.length * millis_per_character * random_variation).to_i }
    }
  end

  def random_variation
    ((100 - SPEED_VARIATION) + rand(2 * SPEED_VARIATION)) / 100.0
  end

  def add_line_breaks
    break_on_dots
    break_on_some_commas
    remove_dots_from_end_of_lines
    downcase_except_pronoun
  end

  def break_on_dots
    @message.gsub!(/\.\ /) { |match|
      match += @breaks.pop
    }
  end

  def break_on_some_commas
    @message.gsub!(/\,\ /) { |match|
      match += @breaks.pop.to_s if rand > 0.5
      match
    }
  end

  def remove_dots_from_end_of_lines
    @message.gsub!(/\.\ \n/, "\n")
  end

  def downcase_except_pronoun
    @message.gsub!(/^[^I]|I[a-zA-z]/, &:downcase)
  end

  def millis_per_character
    60000 / CHARACTERS_PER_MINUTE
  end

  def max_line_breaks
    max_breaks = @message.length / AVERAGE_LINE_LENGTH
    number_of_dots = @message.count(".")

    [ max_breaks, number_of_dots ].max
  end
end

