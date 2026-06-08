Feature: RSVP to a Meal
  As a registered user
  I want to RSVP to meal posts created by other users
  So that the host knows who plans to attend

  Background:
    Given a host user exists with email "host@example.com"
    And a guest user exists with email "guest@example.com"
    And a meal post "Sunday Brunch" exists created by "host@example.com"

  # ─── Happy Paths ────────────────────────────────────────────────────────────

  Scenario: Guest RSVPs as going to a meal
    Given I am logged in as "guest@example.com"
    When I visit the "Sunday Brunch" meal post
    And I click the "I'm Going" RSVP button
    Then the "I'm Going" button should be highlighted as active

  Scenario: Guest changes their RSVP from going to maybe
    Given I am logged in as "guest@example.com"
    And I have already RSVPed "going" to "Sunday Brunch"
    When I visit the "Sunday Brunch" meal post
    And I click the "Maybe" RSVP button
    Then the "Maybe" button should be highlighted as active
    And the "I'm Going" button should not be highlighted as active

  Scenario: Guest cancels their RSVP by clicking the active status again
    Given I am logged in as "guest@example.com"
    And I have already RSVPed "going" to "Sunday Brunch"
    When I visit the "Sunday Brunch" meal post
    And I click the "I'm Going" RSVP button
    Then no RSVP button should be highlighted as active

  # ─── Sad Paths ──────────────────────────────────────────────────────────────

  Scenario: Host does not see RSVP buttons on their own meal
    Given I am logged in as "host@example.com"
    When I visit the "Sunday Brunch" meal post
    Then I should not see "Are you going?"
    And I should not see any RSVP buttons

  Scenario: Unauthenticated user is redirected to sign-in when submitting an RSVP
    Given I am not logged in
    When I submit an RSVP to the "Sunday Brunch" meal as "going"
    Then I should be redirected to the sign-in page

  Scenario: Guest cannot RSVP to a meal that has already passed
    Given I am logged in as "guest@example.com"
    And the meal "Sunday Brunch" has already passed
    When I visit the "Sunday Brunch" meal post
    Then I should see "RSVPs are locked after the meal."
    And I should not see any RSVP buttons
