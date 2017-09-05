module Bullshit
  class Generator
    def self.produce
      self.new.generate
    end

    def generate
      random_suggestion_form +
        " " +
        sample +
        random_conjunction +
        sample
    end

    private

    def sample
      [ random_verb,
        random_adjective,
        random_noun ].join(" ")
    end

    def random_suggestion_form
      Lexicon::SuggestionForms.sample
    end

    def random_verb
      Lexicon::Verbs.sample
    end

    def random_adjective
      Lexicon::Adjectives.sample
    end

    def random_noun
      Lexicon::Nouns.sample
    end

    def random_conjunction
      Lexicon::Conjuctions.sample
    end
  end
end

