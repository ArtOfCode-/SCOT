class AddAPIKeyToAPITokens < ActiveRecord::Migration[5.1]
  def change
    add_reference :api_tokens, :api_keys, foreign_key: true
  end
end
