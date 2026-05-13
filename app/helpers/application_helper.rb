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

  # Returns the restrictions the current user has that this post doesn't accommodate.
  def unmet_dietary_restrictions(post)
    return [] unless user_signed_in? && current_user.dietary_restrictions.present?
    current_user.dietary_restrictions - (post.dietary_restrictions || [])
  end
end
