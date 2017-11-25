class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def authorized_to?(action, resource)
    potentials = UserAuthorization.where(user: self, resource: resource).where('expires_at > ?', DateTime.now)
    potentials.map { |p| p.valid_on.split(',').include? action.to_s }.any?
  end

  def authorization_for(action, resource)
    potentials = UserAuthorization.where(user: self, resource: resource)
    valid = potentials.map { |p| p.valid_on.split(',').include?(action.to_s) ? p.id : nil }.compact
    UserAuthorization.where(id: valid)
  end

  has_many :spam_reviews
  has_many :dedupe_reviews
  has_many :suggested_edits
  has_many :read_notifications
  has_many :notifications, through: :read_notifications
  has_many :dispatch_contacts, class_name: 'Dispatch::ContactAttempt', foreign_key: 'user_id'
  has_and_belongs_to_many :dispatch_requests, class_name: 'Dispatch::Request', join_table: 'dispatch_requests_users', as: :assignees
end
