class Notification < ApplicationRecord
  has_many :read_notifications, dependent: :destroy
  has_many :users, through: :read_notifications
  belongs_to :creator, class_name: 'User'

  def add_users(ids)
    ReadNotification.mass_insert([:user_id, :notification_id, :created_at, :updated_at],
                                 ids.map { |i| [i.to_i, id, DateTime.now, DateTime.now] })
  end
end
