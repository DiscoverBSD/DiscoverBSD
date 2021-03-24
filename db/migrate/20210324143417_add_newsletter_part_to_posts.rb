class AddNewsletterPartToPosts < ActiveRecord::Migration[6.1]
  def change
    add_column :posts, :newsletter_part, :string, null: false, default: 'news'
    add_index :posts, :newsletter_part
  end
end
