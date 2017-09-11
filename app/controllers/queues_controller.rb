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
end
