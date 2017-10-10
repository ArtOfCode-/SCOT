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
    %i[developer admin triage rescue medical broadcast miner]
  end

  def self.can_grant?(user, role)
    if [:admin, :medical].include? role
      user.has_role? :developer
    else
      role != :developer
    end
  end
end
