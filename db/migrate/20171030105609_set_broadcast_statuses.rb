class SetBroadcastStatuses < ActiveRecord::Migration[5.1]
  def change
    Rails.application.load_seed
    Broadcast::Item.joins(:translations).where(translations: { status: Translations::Status['Completed'] })
                   .update_all(status_id: Broadcast::Status['Finalized'].id)
    Broadcast::Item.joins(:translations).where(translations: { status: Translations::Status['Pending Review'] })
                   .update_all(status_id: Broadcast::Status['Translated'].id)
    Broadcast::Item.joins(:translations)
                   .where.not(translations: { status: [Translations::Status['Completed'], Translations::Status['Pending Review']] })
                   .update_all(status_id: Broadcast::Status['Pending Translation'].id)
  end
end
