module ApplicationHelper
  def motif_image_url(post)
    url = if post.present?
            post_url(slug: post.slug)
          else
            root_url
          end
    "https://motif.imgix.com/i?url=#{u url}&image_url=#{u image_url('/img/nik-shuliahin-rkFIIE9PxH0-unsplash.jpg') }&color=88898b&logo_url=https%3A%2F%2Fi.ibb.co%2FZTr5683%2Fdiscoverbsd.png&logo_alignment=top%2Ccenter&text_alignment=bottom%2Ccenter&logo_padding=70&font_family=Avenir%20Next%20Demi%2CBold&text_color=1d1d1d"
  end

  def add_utm_source url
    if URI(url).query.present?
      url + "&utm_source=discoverbsd"
    else
      url + "?utm_source=discoverbsd"
    end
  end
end
