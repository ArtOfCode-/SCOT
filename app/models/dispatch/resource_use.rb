class Dispatch::ResourceUse < ApplicationRecord
  belongs_to :resource, class_name: 'Dispatch::Resource'
  belongs_to :request, class_name: 'RescueRequest'
end
