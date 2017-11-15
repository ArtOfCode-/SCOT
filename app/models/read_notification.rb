class ReadNotification < ApplicationRecord
  belongs_to :notification
  belongs_to :user
end
