class RescueRequestsController < ApplicationController
  def new
  end

  def create
    request = Disaster.find(params[:disaster_id]).rescue_requests.create(lat: params[:lat], long: params[:long])
    queue_assess request
    render plain: request.id
  end

  def update_short
    request = RescueRequest.find(params[:person_id])
    request.update(params.permit(RescueRequest.column_names - %w[id disaster_id created_at updated_at needs_deduping needs_spam_check needs_validation key]).to_h)
    queue_assess request
  end

  def update_long
    request = RescueRequest.find(params[:person_id])
    request.update(params.permit(RescueRequest.column_names - %w[id disaster_id created_at updated_at needs_deduping needs_spam_check needs_validation key]).to_h)
    queue_assess request
    redirect_to root_path
  end

  private

  def queue_assess(request)
    request.needs_deduping = needs_deduping? request
    request.needs_spam_check = needs_spam_check? request
    request.needs_validation = needs_validation? request
    request.save
  end

  def needs_deduping?(request)
    attribute_queries = %w[email name phone].map { |a| "#{a} LIKE '%#{request.send(a)}%'" unless request.send(a).nil? || request.send(a).empty? }.reject(&:nil?).reject(&:empty?)
    RescueRequest.exists?(attribute_queries.join(' OR '))
  end

  def needs_spam_check?(request)
    !request.review_tasks.exists?(type: "spam")
  end

  def needs_validation?(request)
    false
  end
end
