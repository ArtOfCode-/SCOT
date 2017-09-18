class QueuesController < ApplicationController
  def dedupe
    @original = RescueRequest.find_by(dupe_of: nil)
    if @original.nil?
      redirect_to :disasters
      return
    end
    @disaster = @original.disaster
    possible_duplicate_columns = %w[twitter phone email medical conditions extra_details street_address]
    filtered_request = @original.attributes.select { |col, _val| possible_duplicate_columns.include? col }
    conditions = filtered_request.map { |col, val| " #{col} LIKE #{ActiveRecord::Base.connection.quote("%#{val.to_s}%")}" unless val.to_s.empty? }.reject { |i| i.to_s.empty? }.join(" OR ")
    @suggested_dupes = RescueRequest.where(conditions)
  end

  # Dupe_of 0 means that it's a new record
  def dedupe_complete
    if params[:dupe_of]
      current_user.dedupe_reviews.create(rescue_request_id: params[:original_id], outcome: "dupe", dupe_of_id: params[:dupe_of], suggested_duplicates: params[:suggested_duplicates])
      RescueRequest.find(params[:rescue_request_id]).update(dupe_of: params[:dupe_of])
    elsif params[:skip]
      current_user.dedupe_reviews.create(rescue_request_id: params[:original_id], outcome: "skip", suggested_duplicates: params[:suggested_duplicates])
    elsif params[:not]
      current_user.dedupe_reviews.create(rescue_request_id: params[:original_id], outcome: "not", dupe_of_id: 0, suggested_duplicates: params[:suggested_duplicates])
      RescueRequest.find(params[:rescue_request_id]).update(dupe_of: 0)
    end
    redirect_to action: :dedupe
  end

  def spam
    @rescue_request = RescueRequest.find_by(spam: nil)
    if @rescue_request.nil?
      redirect_to :disasters
      return
    end
    @disaster = @rescue_request.disaster
  end

  def spam_complete
    parse = {spam: true, not: false, skip: nil}
    current_user.spam_reviews.create(rescue_request_id: params[:rescue_request_id], outcome: params[:outcome])
    RescueRequest.find(params[:rescue_request_id]).update(spam: parse[params[:outcome].to_sym])
    redirect_to action: :spam
  end

  def suggested_edit
  end

  def suggested_edit_complete
  end
end
