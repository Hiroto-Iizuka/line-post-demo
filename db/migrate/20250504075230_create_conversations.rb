class CreateConversations < ActiveRecord::Migration[7.2]
  def change
    create_table :conversations do |t|
      t.string :line_user_id
      t.string :state
      t.string :title
      t.text :content

      t.timestamps
    end
  end
end
