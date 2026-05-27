module PostsHelper
  def meal_time_range(post)
    return nil unless post.meal_date
    start_str = post.meal_date.strftime("%l:%M %p").strip
    end_time  = post.meal_date + (post.duration_minutes || 60).minutes
    end_str   = end_time.strftime("%l:%M %p").strip
    "#{start_str} – #{end_str}"
  end
end
