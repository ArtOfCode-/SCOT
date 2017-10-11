class CreateTranslationPriorities < ActiveRecord::Migration[5.1]
  def change
    create_table :translation_priorities do |t|
      t.string :name
      t.text :description
      t.integer :index

      t.timestamps
    end
  end
end
