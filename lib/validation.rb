require 'validation/validator'

module Validation

  class << self
    private

    def included(mod)
      mod.module_eval do
        extend Validation::Rules
      end
    end
  end
end
