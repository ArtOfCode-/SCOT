class SuggestedEdit < ApplicationRecord
  belongs_to :resource, polymorphic: true
  belongs_to :user
  belongs_to :reviewed_by, class_name: 'User', optional: true

  serialize :new_values

  def approve(reviewer)
    resource.update new_values
    update(reviewed_by: reviewer, result: 'Approved')
  end

  def reject(reviewer)
    update(reviewed_by: reviewer, result: 'Rejected')
  end
end
