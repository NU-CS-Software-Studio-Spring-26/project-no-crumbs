class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[about legal]

  def about; end
  def legal; end
end
