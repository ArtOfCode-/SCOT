class Translation < ApplicationRecord
  belongs_to :source_lang, class_name: 'Translations::Language'
  belongs_to :target_lang, class_name: 'Translations::Language'
  belongs_to :requester, class_name: 'User'
  belongs_to :assignee, class_name: 'User', optional: true
  belongs_to :status, class_name: 'Translations::Status', optional: true
  belongs_to :priority, class_name: 'Translations::Priority'
  belongs_to :broadcast_item, class_name: 'Broadcast::Item', optional: true
  belongs_to :duplicate_of, class_name: 'Translation', optional: true
  has_many :duplicates, class_name: 'Translation', foreign_key: 'duplicate_of_id'

  after_create do
    changes = {}
    unless status.present?
      changes[:status] = Translations::Status['Pending Assessment']
    end

    changes[:content] = if content.present?
                          content.strip.gsub(/\n{3,}/, "\n\n")
                        else
                          ''
                        end
    changes[:final] = if final.present?
                        final.strip.gsub(/\n{3,}/, "\n\n")
                      else
                        ''
                      end

    update(**changes)
  end

  def make_duplicate(id)
    dupe_of = Translation.find_by id: id
    return unless dupe_of.present?
    update(content: dupe_of.content, final: dupe_of.final, duplicate_of: dupe_of, status: Translations::Status['Rejected'])
  end
end
