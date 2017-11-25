class Dispatch::ResourceType < ApplicationRecord
  has_many :resources, class_name: 'Dispatch::Resource', foreign_key: 'resource_type_id'

  validates :name, uniqueness: true

  def self.[](key)
    find_by name: key
  end
end
