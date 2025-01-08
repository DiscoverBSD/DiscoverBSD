module ApplicationHelper
  def og_image_url(title)
    "https://og.tailgraph.com/og?fontFamily=Roboto&title=#{u title} \
    &titleTailwind=text-gray-800%20font-bold%20text-6xl \
    &bgUrl=https%3A%2F%2Fdiscoverbsd.com%2Fimg%2Fnik-shuliahin-rkFIIE9PxH0-unsplash.jpg \
    &bgTailwind=bg-white \
    &overlay=1 \
    &overlayTailwind=bg-yellow-200%20opacity-30"
  end

  def discoverbsd_utm_source_url url
    if URI(url).query.present?
      url + "&utm_source=discoverbsd"
    else
      url + "?utm_source=discoverbsd"
    end
  end

  def bsdweekly_utm_source_url url
    if URI(url).query.present?
      url + "&utm_source=bsdweekly"
    else
      url + "?utm_source=bsdweekly"
    end
  end
end
