class QueuesController < ApplicationController
  def spam
    @request = RescueRequest.find_by(needs_spam_check: true)
  end

  def validation
    @request = RescueRequest.find_by(needs_validation: true)
  end

  def deduping
    @request = RescueRequest.find_by(needs_deduping: true)
    criteria = @request.attributes.map { |col, val| " #{col} LIKE #{val}" unless val.nil? || val.empty? }.reject { |i| i.nil? || i.empty? }.join(" OR ")
    @similar_requests = RescueRequest.where(criteria)
  end

  def dedupe_skip
    RescueRequest.find(params.permit(:request_id)[:request_id]).review_tasks.create(user_id: @user.id, type: "dedupe", outcome: "skip")
  end

  def dedupe_done
    RescueRequest.find(params.permit(:request_id)[:request_id]).review_tasks.create(user_id: @user.id, type: "dedupe", outcome: "done")
    RescueRequest.find(params.permit(:request_id)[:request_id]).update(needs_deduping: false)
  end
end
