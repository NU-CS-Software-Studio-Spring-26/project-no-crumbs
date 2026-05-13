module ApplicationHelper
  DIETARY_RESTRICTION_OPTIONS = {
    "vegetarian"     => "Vegetarian",
    "vegan"          => "Vegan",
    "gluten_free"    => "Gluten-Free",
    "dairy_free"     => "Dairy-Free",
    "nut_free"       => "Nut-Free",
    "shellfish_free" => "Shellfish-Free",
    "halal"          => "Halal",
    "kosher"         => "Kosher"
  }.freeze

  def dietary_restriction_label(key)
    DIETARY_RESTRICTION_OPTIONS[key] || key.to_s.humanize
  end

  def unmet_dietary_restrictions(post)
    return [] unless user_signed_in? && current_user.dietary_restrictions.present?
    current_user.dietary_restrictions - (post.dietary_restrictions || [])
  end

  def avatar_tag(user, size: :md)
    css = "avatar avatar-#{size}"
    if user.avatar.attached?
      image_tag user.avatar, class: css, alt: user.username
    else
      content_tag(:div, user.username[0].upcase, class: "#{css} gc-#{user.id % 8}")
    end
  end
end
