module ApplicationHelper
  def avatar_tag(user, size: :md)
    css = "avatar avatar-#{size}"
    if user.avatar.attached?
      image_tag user.avatar, class: css, alt: user.username
    else
      content_tag(:div, user.username[0].upcase, class: "#{css} gc-#{user.id % 8}")
    end
  end
end
