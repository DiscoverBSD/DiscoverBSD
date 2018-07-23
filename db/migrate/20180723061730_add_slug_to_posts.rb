class AddSlugToPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :slug, :string
    Post.all.each {|post| post.slug = SecureRandom.hex(5) and post.save unless post.slug.present?}
    change_column_null :posts, :slug, false
    add_index :posts, :slug, unique: true
  end
end
