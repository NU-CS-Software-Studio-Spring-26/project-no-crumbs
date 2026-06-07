class PostsController < ApplicationController
  before_action :authenticate_user!, only: %i[ index new create edit update destroy generate_description ]
  before_action :set_post, only: %i[ show edit update destroy ]
  before_action :require_owner!, only: %i[ edit update destroy ]
  before_action :set_user_communities, only: %i[ new edit create update ]

  # GET /posts or /posts.json
  def index
    if user_signed_in?
      @query = params[:q].to_s.strip
      collection = if admin?
        Post.active
      else
        visible_ids = current_user.friends.ids + [ current_user.id ]
        Post.active.where(user_id: visible_ids)
      end
      collection = if @query.present?
        collection.search_meals(@query)
      else
        collection.order(meal_date: :asc)
      end
      @pagy, @posts = pagy(:offset, collection)
    else
      @pagy = nil
      @posts = Post.none
    end
  end

  # GET /posts/1 or /posts/1.json
  def show
  end

  # POST /posts/generate_description
  def generate_description
    title = params[:title].to_s.strip
    meal_description = params[:meal_description].to_s.strip
    return render json: { error: "Title is required" }, status: :bad_request if title.blank?
    require "net/http"

    uri = URI("https://api.openai.com/v1/chat/completions")
    req = Net::HTTP::Post.new(uri)
    req["Authorization"] = "Bearer #{ENV['OPENAI_API_KEY']}"
    req["Content-Type"] = "application/json"
    req.body = {
      model: "gpt-4o-mini",
      messages: [
        {
          role: "system",
          content: "You write short, warm, and playful descriptions for No Crumbs — a social app where friends share home-cooked meals and dinner parties. Keep it to 3-4 sentences. Focus on the vibe: the cozy atmosphere, the company, the occasion. Only mention specific food if the title or meal description makes it explicit — never invent dishes that aren't stated. Do not use quotation marks."
        },
        {
          role: "user",
          content: "Write a cute description for a meal or event called: #{title}\n\nMeal description: #{meal_description}"
        }
      ],
      max_tokens: 150,
      temperature: 0.85
    }.to_json

    result = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
    body = JSON.parse(result.body)
    description = body.dig("choices", 0, "message", "content")&.strip

    render json: { description: description }
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts or /posts.json
  def create
    @post = Post.new(post_params)
    @post.user = current_user

    respond_to do |format|
      if @post.save
        @post.update_column(:cover_photo_url, UnsplashService.fetch_photo_url(@post.title))
        format.html { redirect_to post_path(@post, from_create: 1), notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to post_path(@post, from_edit: 1), notice: "Post was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy!

    respond_to do |format|
      format.html { redirect_to posts_path, notice: "Post was successfully deleted.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params.expect(:id))
    end

    def set_user_communities
      @user_communities = current_user.communities
    end

    def require_owner!
      redirect_to @post, alert: "You can only modify your own meals." unless @post.user == current_user || admin?
    end

    # Only allow a list of trusted parameters through.
    def post_params
      p = params.require(:post).permit(:title, :description, :address, :meal_date, :duration_minutes, { community_ids: [] }, dietary_restrictions: [])
      p[:dietary_restrictions] = (p[:dietary_restrictions] || []).reject(&:blank?)
      p
    end
end
