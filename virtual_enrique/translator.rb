module VirtualEnrique
  class Translator
    SUBSTITUTIONS = [
      [ /sh/, [ "ch" ] ],
      [ /ss/, [ "ch" ] ],
      [ /s/, [ "ch" ] ],
      [ /\,\ /, [ ", ", ", kind of, " ] ],
      [ /\. /, [". ", ". It's crazy. ", ". For chure. "] ]
    ]

    def self.translate(message)
      self.new.translate(message)
    end

    def translate(message)
      [ Lexicon::Prefixes.sample,
        Lexicon::Infixes.sample,
        apply_substitutions(message),
        Lexicon::Infixes.sample,
        Lexicon::Suffixes.sample ].join
    end

    private

    def apply_substitutions(message)
      SUBSTITUTIONS.reduce(message) do |msg, (regex, values)|
        msg.gsub(regex) do 
        values.sample
      end
      end
    end
  end
end

