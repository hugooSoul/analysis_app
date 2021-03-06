class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  SENTIM_ENDPOINT = 'https://sentim-api.herokuapp.com/api/v1/'

  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.all
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    # Foreach to read files in Post
    payload = {
      text: 'In vestibulum lacinia diam, nec egestas libero hendrerit id. Mauris vitae mi eu tortor auctor ultrices pretium id risus.'
    }.to_json
    raw_response = Faraday.new(url: SENTIM_ENDPOINT)
                           .post(
                               nil,
                               payload,
                               accept: 'application/json',
                               'content-type': 'application/json'
                           )
    @sentim_response = JSON.parse(raw_response.body)
    #puts @sentim_response
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        RemovePostsJob.set(wait: 12.hours).perform_later(@post)
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:title, files: [])
    end
end
