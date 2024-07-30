module ApplicationSeeder
  class CreateOrUpdateMatch
    def initialize(panda_score_match)
      @panda_score_match = panda_score_match
    end

    def call
      panda_score_match.upsert_model
    end

    private

    attr_reader :panda_score_match
  end
end