class SuggestedEdit < ApplicationRecord
  belongs_to :resource, polymorphic: true
  belongs_to :user
  belongs_to :reviewed_by, class_name: 'User', optional: true

  serialize :new_values
  serialize :old_values

  def approve(reviewer)
    resource.update new_values
    update(reviewed_by: reviewer, result: 'Approved', reviewed_at: DateTime.now)
  end

  def reject(reviewer)
    update(reviewed_by: reviewer, result: 'Rejected', reviewed_at: DateTime.now)
  end

  def changes
    new_values.reject { |nk, nv| old_values[nk] == nv }
  end
end
