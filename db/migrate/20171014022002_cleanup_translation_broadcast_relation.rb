class CleanupTranslationBroadcastRelation < ActiveRecord::Migration[5.1]
  def change
    add_reference :translations, :broadcast_item

    reversible do |dir|
      dir.up do
        Broadcast::Item.all.each do |item|
          status = Translations::Status['Pending Assessment']
          if item.translation.nil? || item.translation.empty?
            content = item.content
            translation = item.translation
            from = Translations::Language['en-US']
            to = Translations::Language['es-PR']
          elsif item.content.nil? || item.content.empty?
            content = item.translation
            translation = item.content
            from = Translations::Language['es-PR']
            to = Translations::Language['en-US']
          else
            # Em... what else can I do? I don't know direction.
            content = item.content
            translation = item.translation
            from = Translations::Language['en-US']
            to = Translations::Language['es-PR']
            status = Translations::Status['Completed']
          end
          puts "#{from.name}\t#{to.name}\t#{status.name}\t#{content}\t#{translation}\t#{item.inspect}"
          item.translations.create(content: content, final: translation, source_lang: from, target_lang: to, deliver_to: 'SCOT', due: DateTime.now.utc,
                                   requester: User.find(1), status: status, priority: Translations::Priority['Semi-Urgent'])
        end
      end
      dir.down do
        # The code below feels like it should work, but does not. If you need to roll this back, good luck.
        raise "This can't be rolled back!"
        # Translation.all.each do |translation|
        #   broadcast_item = translation.broadcast_item
        #   next if broadcast_item.nil?
        #   if translation.source_lang == Translations::Language['en-US']
        #     broadcast_item.content = translation.content
        #     broadcast_item.translation = translation.final
        #   elsif translation.source_lang == Translations::Language['es-PR']
        #     broadcast_item.content = translation.final
        #     broadcast_item.translation = translation.content
        #   end
        #   broadcast_item.save
        # end
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
