class ChangeAPITokenAPIKeyAssociationName < ActiveRecord::Migration[5.1]
  def change
    rename_column :api_tokens, :api_keys_id, :api_key_id
  end
end
