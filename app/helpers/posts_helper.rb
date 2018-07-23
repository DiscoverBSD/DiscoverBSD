module PostsHelper
  def markdown_to_html(text)
    renderer = Redcarpet::Render::HTML.new
    markdown = Redcarpet::Markdown.new(renderer)
    markdown.render(text)
  end
end
