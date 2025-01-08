module ApplicationHelper
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
