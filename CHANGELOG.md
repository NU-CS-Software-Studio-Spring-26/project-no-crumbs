# Changelog

## v2.0.0 — Full Feature Release (2026-06-08)

### What's new

- AI-generated meal descriptions from your meal title
- Calendar export (.ics) to Google Calendar or Apple Calendar, with meal duration
- Email notifications for likes, comments, and RSVPs; opt out from your profile
- Sign in with Google or Discord via OAuth
- Communities — create, join, and share meals into groups; browse a "My Communities" view
- Dietary restriction tags on meals
- Meal location/address field
- Meal sharing via clipboard link
- Profile stats showing RSVP counts across all meals
- Full-text user search with lazy loading
- Admin panel for moderating posts and users
- In-app notification bell with mark-all-read

### Improvements

- Home page feature cards link directly to their respective pages
- Meal feed cards are fully clickable
- Past dates blocked when scheduling a meal (server + client)
- Footer pinned to the bottom of every page
- Pagination on meals, users, and communities
- Unsplash auto-photos on meal cards
- "Today" / "Tomorrow" badges on meal cards
- Unsaved changes warning on the new meal form
- Back-to-top button
- Change password on profile edit page
- Community guidelines page

### Accessibility

- Skip link, ARIA labels, and `role=alert` on flash messages
- Proper `h1` headings on all pages
- Contrast and readability fixes throughout

### Quality

- RSpec model tests for Post, RSVP, and Friendship
- Cucumber integration tests for RSVP flow
- Full CI: Brakeman, bundler-audit, RuboCop, erb_lint, Minitest, RSpec

---

## v1.0.0 — MVP (2026-05-04)

### What's included

- User authentication (sign up, sign in, sign out)
- Meal posting with date/time
- Friend requests and social feed
- Meals filtered to friends only
- 36-hour meal archiving
- Profile pages with meal history
- People search
- Mobile-responsive design
