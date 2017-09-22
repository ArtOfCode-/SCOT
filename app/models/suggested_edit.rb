class SuggestedEdit < ApplicationRecord
  belongs_to :resource, polymorphic: true
  belongs_to :user

  serialize :new_values
end
