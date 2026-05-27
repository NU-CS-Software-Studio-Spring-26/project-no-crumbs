require "icalendar"
require "icalendar/tzinfo"

EXPORT_TZID = "America/Chicago"

class RsvpsController < ApplicationController
  before_action :set_post, except: [ :export ]
  before_action :authorize_rsvp!, except: [ :export ]

  def export
    rsvps = current_user.rsvps
                        .includes(:post)
                        .where(status: %w[going maybe])
                        .select { |r| r.post.meal_date.present? }
                        .sort_by { |r| r.post.meal_date }

    cal = Icalendar::Calendar.new
    cal.prodid = "-//No Crumbs//NoCrumbs//EN"
    cal.add_timezone TZInfo::Timezone.get(EXPORT_TZID).ical_timezone(Time.now)

    rsvps.each do |rsvp|
      post = rsvp.post
      # meal_date is stored as UTC but entered without timezone context, so the
      # digits are correct for display — we label them CST so calendars show the
      # same time the app shows.
      naive = post.meal_date.strftime("%Y%m%dT%H%M%S")

      cal.event do |e|
        going = rsvp.status == "going"
        e.dtstart     = Icalendar::Values::DateTime.new(naive, "tzid" => EXPORT_TZID)
        e.dtend       = Icalendar::Values::DateTime.new((post.meal_date + (post.duration_minutes || 60).minutes).strftime("%Y%m%dT%H%M%S"), "tzid" => EXPORT_TZID)
        e.summary     = "#{going ? "[GOING]" : "[MAYBE]"} #{post.title}"
        e.description = post.description.presence || ""
        e.description += "\n\nView on No Crumbs: #{post_url(post)}"
      end
    end

    cal.publish

    send_data cal.to_ical,
              type: "text/calendar; charset=utf-8",
              filename: "no-crumbs-meals.ics",
              disposition: "attachment"
  end

  def create
    @rsvp = @post.rsvps.find_or_initialize_by(user: current_user)
    was_new = @rsvp.new_record?

    if @rsvp.status == params[:status]
      @rsvp.destroy
      @rsvp = nil
    else
      @rsvp.status = params[:status]
      @rsvp.save!
      if was_new
        Notification.create_notification(action: "rsvp", recipient: @post.user, actor: current_user, notifiable: @rsvp)
      end
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @post }
    end
  end

  def destroy
    @rsvp = @post.rsvps.find_by(user: current_user)
    @rsvp&.destroy
    @rsvp = nil

    respond_to do |format|
      format.turbo_stream { render :create }
      format.html { redirect_to @post }
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def authorize_rsvp!
    if @post.user == current_user
      redirect_to @post, alert: "You can't RSVP to your own meal."
    elsif @post.archived?
      redirect_to @post, alert: "This meal has already passed."
    end
  end
end
