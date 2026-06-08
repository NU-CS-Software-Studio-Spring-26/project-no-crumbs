class RegistrationsController < Devise::RegistrationsController
  before_action :reject_google_account, only: %i[edit update]

  protected

  def after_update_path_for(resource)
    edit_user_path(resource)
  end

  private

  def reject_google_account
    if current_user&.google_account?
      redirect_to edit_user_path(current_user), alert: "Your account uses Google sign-in, so there's no password to change."
    end
  end
end
