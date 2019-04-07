class ResponsesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    message_body = params["Body"]
    from_number = params["From"]

    create_vote(from_number, message_body)
    vote = Vote.new( voter: from_number)

    TwilioTextMessenger.new.send_vote_receipt
  end

end
