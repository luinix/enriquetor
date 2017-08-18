class Translator
  PREFIXES = [
    "Listen",
    "Believe me"
  ]

  SUFFIXES = [
    "a hundred percent chure",
    "I'm telling you",
    "I guarantee you",
    "yes or yes",
    "we don't really have a choice do we?",
    "and well you know the rest"
  ]

  CONJUNCTIONS = [
    ", ",
    ", basically, ",
    ", like, ",
    ", literally, ",
    ", definitely, "
  ]

  SUBSTITUTIONS = [
    [ /sh/, [ "ch" ] ],
    [ /s/, [ "ch" ] ],
    [ /\,\ /, [ ", ", ", kind of, " ] ],
    [ /\. /, [". ", ". It's crazy. ", ". For chure. "] ]
  ]

  def self.translate(message)
    self.new.translate(message)
  end

  def translate(message)
    [ random_prefix,
      random_conjunction,
      apply_substitutions(message),
      random_conjunction,
      random_suffix ].join
  end

  private

  def random_prefix
    PREFIXES.sample
  end

  def random_suffix
    SUFFIXES.sample
  end

  def random_conjunction
    CONJUNCTIONS.sample
  end

  def apply_substitutions(message)
    SUBSTITUTIONS.reduce(message) do |msg, (regex, values)|
      msg.gsub(regex) do 
        values.sample
      end
    end
  end
end

