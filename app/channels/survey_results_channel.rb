class SurveyResultsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "survey_results_channel"
    #we wanna interpolate the survey id
  end

  def unsubscribed
    stop_all_streams
  end

  def vote(data)
    Vote.create!(value: data['vote_value'].to_i)
  end
end