class CleanupTranslationBroadcastRelation < ActiveRecord::Migration[5.1]
  def change
    add_reference :translations, :broadcast_item

    reversible do |dir|
      dir.up do
        Broadcast::Item.all.each do |item|
          if item.translation.nil?
            content = item.content
            translation = item.translation
            from = Translations::Language['en-US']
            to = Translations::Language['es-PR']
          elsif item.content.nil?
            content = item.translation
            translation = item.content
            from = Translations::Language['es-PR']
            to = Translations::Language['en-US']
          else
            # Em... what else can I do?
            content = item.content
            translation = item.translation
            from = Translations::Language['en-US']
            to = Translations::Language['es-PR']
          end
          ActiveRecord::Base.transaction do
            t = Translation.create(content: content, final: translation, source_lang: from, target_lang: to, deliver_to: 'SCOT', due: DateTime.now.utc,
              requester: User.find(1), priority: Translations::Priority['Semi-Urgent'], broadcast_item_id: item.id)
            item.update(translation: t)
          end
        end
      end
      dir.down do
      end
    end

    reversible do |dir|
      dir.up do
        remove_columns :broadcast_items, :translation, :content, :request_id
      end
      dir.down do
        add_column :broadcast_items, :translation, :text
        add_column :broadcast_items, :content, :text
        add_column :broadcast_items, :request_id, :bigint
      end
    end
  end
end
