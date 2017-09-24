class SuggestedEdit < ApplicationRecord
  belongs_to :resource, polymorphic: true
  belongs_to :user
  belongs_to :reviewed_by, class_name: 'User', optional: true

  serialize :new_values
end
