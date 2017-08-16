require_relative "suggestion_forms"
require_relative "verbs"
require_relative "adjectives"
require_relative "nouns"

class BullShitGenerator
  def self.generate
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
    SuggestionForms.sample
  end

  def random_verb
    Verbs.sample
  end

  def random_adjective
    Adjectives.sample
  end

  def random_noun
    Nouns.sample
  end

  def random_conjunction
    [ ", so we can ",
      ". That way we will ",
      ". Even "].sample
  end
end

