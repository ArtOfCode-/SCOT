class QueuesController < ApplicationController
  def spam
    @request = RescueRequest.find_by(needs_spam_check: nil)
  end

  def spam_spam
    request = RescueRequest.find(params[:request_id])
    request.update(needs_spam_check: false)
    request.review_tasks.create(user_id: current_user.id, review_type: "spam", outcome: "spam")
    redirect_to :spam_queue
  end

  def spam_not
    request = RescueRequest.find(params[:request_id])
    request.update(needs_spam_check: false)
    request.review_tasks.create(user_id: current_user.id, review_type: "spam", outcome: "not spam")
    redirect_to :spam_queue
  end

  def validation
    @request = RescueRequest.find_by(needs_validation: true)
  end

  def deduping
    @request = RescueRequest.find_by(needs_deduping: nil)
    criteria = @request.attributes.select {|col, _val| %w[lat long twitter phone email medical conditions extra_details street_address].include? col }.map { |col, val| " #{col} LIKE #{ActiveRecord::Base.connection.quote(val.to_s)}" unless val.nil? || val.to_s.empty? }.reject { |i| i.nil? || i.empty? }.join(" OR ")
    @similar_requests = RescueRequest.where(criteria)
  end

  def dedupe_skip
    request = RescueRequest.find(params[:request_id])
    request.review_tasks.create(user_id: current_user.id, review_type: "dedupe", outcome: "skip")
    redirect_to :dedupe_queue
  end

  def dedupe_yes
    request = RescueRequest.find(params[:request_id])
    # TODO: Dedupe. Dupe of params[:dupe_of]
    request.review_tasks.create(user_id: @user.id, review_type: "dedupe", outcome: "yes")
    request.update(needs_deduping: false)
    redirect_to :dedupe_queue
  end

  def dedupe_yes_edit
    request = RescueRequest.find(params[:request_id])
    # TODO: Dedupe. Dupe of params[:dupe_of]
    request.review_tasks.create(user_id: @user.id, review_type: "dedupe", outcome: "yes")
    request.update(needs_deduping: false)
    redirect_to # Edit link for record
  end

  def dedupe_no
    request = RescueRequest.find(params[:request_id])
    request.review_tasks.create(user_id: @user.id, review_type: "dedupe", outcome: "no")
    request.update(needs_deduping: false)
    redirect_to :dedupe_queue
  end
end
