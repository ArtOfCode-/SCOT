class Translation < ApplicationRecord
  belongs_to :source_lang, class_name: 'Translations::Language'
  belongs_to :target_lang, class_name: 'Translations::Language'
  belongs_to :requester, class_name: 'User'
  belongs_to :assignee, class_name: 'User', optional: true
  belongs_to :status, class_name: 'Translations::Status', optional: true
  belongs_to :priority, class_name: 'Translations::Priority'
  belongs_to :broadcast_item, class_name: 'Broadcast::Item', optional: true

  after_create do
    changes = {}
    unless status.present?
      changes[:status] = Translations::Status['Pending Assessment']
    end

    changes[:content] = '' unless content.present?

    changes[:final] = '' unless final.present?

    update(**changes)
  end
end
