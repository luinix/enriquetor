require_relative "suggestion_forms"
require_relative "verbs"
require_relative "adjectives"
require_relative "nouns"

class BullShitGenerator
  def self.sample
    self.new.sample
  end

  def sample
    [ random_suggestion_form,
      random_verb,
      random_adjective,
      random_noun ].join(" ")
  end

  private

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
end

