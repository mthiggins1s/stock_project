class UsersController < ApplicationController
  # Signup is public; everything else requires a valid JWT
  before_action :authenticate_request, except: [ :create ]
  before_action :set_user, only: [ :show, :update, :destroy ]

  # === CURRENT USER ===
  def me
    render json: {
      id:         @current_user.id,
      username:   @current_user.username,
      first_name: @current_user.first_name,
      last_name:  @current_user.last_name,
      public_id:  @current_user.public_id
    }, status: :ok
  end

  # === LIST (safe)
  def index
    users = User.select(:id, :username, :first_name, :last_name, :public_id).order(:id)
    render json: users, status: :ok
  end

  # === SHOW
  def show
    render json: {
      id:         @user.id,
      username:   @user.username,
      first_name: @user.first_name,
      last_name:  @user.last_name,
      public_id:  @user.public_id
    }, status: :ok
  end

  # === CREATE (signup)
  def create
    user = User.new(user_params)
    if user.save
      render json: {
        id:         user.id,
        username:   user.username,
        first_name: user.first_name,
        last_name:  user.last_name,
        public_id:  user.public_id
      }, status: :created
    else
      render json: {
        messages: user.errors.full_messages,
        details:  user.errors.to_hash(true)
      }, status: :unprocessable_entity
    end
  end

  # === UPDATE
  def update
    if @user.update(user_params)
      render json: {
        id:         @user.id,
        username:   @user.username,
        first_name: @user.first_name,
        last_name:  @user.last_name,
        public_id:  @user.public_id
      }, status: :ok
    else
      render json: {
        messages: @user.errors.full_messages,
        details:  @user.errors.to_hash(true)
      }, status: :unprocessable_entity
    end
  end

  # === DESTROY
  def destroy
    @user.destroy!
    head :no_content
  rescue ActiveRecord::RecordNotDestroyed
    render json: {
      messages: @user.errors.full_messages,
      details:  @user.errors.to_hash(true)
    }, status: :unprocessable_entity
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user)
          .permit(:username, :email, :first_name, :last_name, :password, :password_confirmation)
  end
end
