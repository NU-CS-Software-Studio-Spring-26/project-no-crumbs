class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[about legal community_guidelines]

  def about; end
  def legal; end
  def community_guidelines; end
end
