class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy ]
  before_action :require_owner!, only: %i[ edit update destroy ]

  # GET /users or /users.json
  def index
    @query = params[:q].to_s.strip
    @users = if @query.present?
      User.where("username ILIKE ? OR email ILIKE ?", "%#{@query}%", "%#{@query}%")
    else
      User.all
    end
  end

  # GET /users/1 or /users/1.json
  def show
    @friendship = Friendship.where(requester: current_user, receiver: @user)
                            .or(Friendship.where(requester: @user, receiver: current_user))
                            .first
    can_see_meals = current_user == @user || current_user.friend_with?(@user)
    if can_see_meals
      @active_posts   = @user.posts.active.order(meal_date: :asc)
      @archived_posts = @user.posts.archived.order(meal_date: :desc)
    else
      @active_posts   = nil
      @archived_posts = nil
    end
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users or /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: "User was successfully created." }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to user_path(@user, direct: 1), notice: "User was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    @user.destroy!

    respond_to do |format|
      format.html { redirect_to users_path, notice: "User was successfully deleted.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params.expect(:id))
    end

    def require_owner!
      redirect_to @user, alert: "You can only modify your own profile." unless @user == current_user
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.expect(user: [ :username, :email, :bio ])
    end
end
