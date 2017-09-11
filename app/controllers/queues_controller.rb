class QueuesController < ApplicationController
  def spam
    @request = RescueRequest.find_by(needs_spam_check: true)
  end

  def validation
    @request = RescueRequest.find_by(needs_validation: true)
  end

  def deduping
    @request = RescueRequest.find_by(needs_deduping: true)
  end
end
