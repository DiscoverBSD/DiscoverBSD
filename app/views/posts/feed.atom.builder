atom_feed do |feed|
  feed.title("DiscoverBSD - The BSD community linklog")
  feed.updated(@posts[0].created_at) if @posts.length > 0

  @posts.each do |post|
    feed.entry(post, url: post_url(slug: post.slug)) do |entry|
      entry.title(post.title)
      entry.content(markdown_to_html(post.description).html_safe, type: 'html')

      entry.author do |author|
        author.name("DiscoverBSD")
      end
    end
  end
end
