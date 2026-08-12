class AddScheduledForToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :scheduled_for, :datetime
    add_index :posts, :scheduled_for
  end
end
