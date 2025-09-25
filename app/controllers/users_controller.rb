class UsersController < ApplicationController
  # Signup is public; everything else requires a valid JWT
  before_action :authenticate_request, except: [ :create ]
  before_action :set_user, only: [ :show, :update, :destroy ]

  # === CURRENT USER ===
  def me
    render json: UserBlueprint.render(@current_user, view: :normal), status: :ok
  end

  # === LIST (safe) ===
  def index
    users = User.select(:id, :username, :first_name, :last_name).order(:id)
    render json: users, status: :ok
  end

  # === SHOW (consistent shape) ===
  def show
    render json: UserBlueprint.render(@user, view: :normal), status: :ok
  end

  # === CREATE (signup) ===
  def create
    user = User.new(user_params)
    if user.save
      render json: UserBlueprint.render(user, view: :normal), status: :created
    else
      render json: {
        messages: user.errors.full_messages,
        details:  user.errors.to_hash(true)
      }, status: :unprocessable_entity
    end
  end

  # === UPDATE ===
  def update
    if @user.update(user_params)
      render json: UserBlueprint.render(@user, view: :normal), status: :ok
    else
      render json: {
        messages: @user.errors.full_messages,
        details:  @user.errors.to_hash(true)
      }, status: :unprocessable_entity
    end
  end

  # === DESTROY ===
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
