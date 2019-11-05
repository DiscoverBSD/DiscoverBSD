module ApplicationHelper
  def motif_image_url(post)
    url = if post.present?
            post_url(slug: post.slug)
          else
            root_url
          end
    "https://motif.imgix.com/i?url=#{u url}&image_url=#{u image_url('/img/gratisography-330H.jpg') }&color=6e6e6e&logo_url=&logo_alignment=bottom%2Cright&text_alignment=top%2Cleft&logo_padding=0&font_family=Avenir%20Next%20Demi%2CBold&text_color=ffffff"
  end

  def add_utm_source url
    if URI(url).query.present?
      url + "&utm_source=discoverbsd"
    else
      url + "?utm_source=discoverbsd"
    end
  end
end
