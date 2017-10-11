class Role < ApplicationRecord
  has_and_belongs_to_many :users, join_table: :users_roles

  belongs_to :resource,
             polymorphic: true,
             optional: true

  validates :resource_type,
            inclusion: { in: Rolify.resource_types },
            allow_nil: true

  scopify

  def self.global_defaults
    %i[developer admin triage rescue medical broadcast miner translator]
  end

  def self.can_grant?(user, role)
    if [:admin, :medical].include? role
      user.has_role? :developer
    elsif user.has_role? :admin
      role != :developer
    elsif user.has_role :channel_lead
      user.roles.where(name: :channel_lead).map { |r| r.resource.grantable_roles.map(&:name) }.flatten.include? role.to_s
    end
  end
end
