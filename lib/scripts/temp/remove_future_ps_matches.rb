require_relative '../../../config/environment'

def future_ps_matches
  PandaScore::Match.where("data->>'status' = 'not_started'")
end

def destroy_future_ps_matches
  future_ps_matches.destroy_all
end

destroy_future_ps_matches