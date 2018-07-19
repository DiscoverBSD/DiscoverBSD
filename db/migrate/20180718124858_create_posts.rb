class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.references :author, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.text :description, null: false
      t.string :url, null: false
      t.boolean :approved, null: false, default: false
      t.references :approved_by, foreign_key: { to_table: :users }
      t.timestamp :approved_at
      t.boolean :declined, null: false, default: false
      t.references :declined_by, foreign_key: { to_table: :users }
      t.timestamp :declined_at
      t.timestamps
    end
  end
end
