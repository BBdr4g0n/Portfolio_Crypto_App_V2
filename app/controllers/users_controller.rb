class UsersController < ApplicationController

  # index / show / new / edit / create / update / destroy
  before_action :set_user, only: [:edit, :update, :show, :destroy]
  before_action :require_user, except: [:new, :create]
  before_action :require_same_user, only: [:edit, :update, :destroy]

  # GET /users or /users.json
  def index
    @users = User.all
  end

  # GET /users/1 or /users/1.json
  def show
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

    if @user.save
      session[:user_id] = @user.id
      flash[:success] = "Welcome #{@user.username}, you've sign up successfully!"
      redirect_to user_path(@user)
    else
      render "new", status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    if @user.update(user_params)
      flash[:success] = "User infos updated"
      redirect_to user_path(@user)
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    @user.destroy
    session[:user_id] = nil
    flash[:danger] = "User #{@user.username} and all account infos deleted!"
    redirect_to root_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:username, :email, :password)
    end

    def require_same_user
      if current_user != @user
        flash[:danger] = "You don't have the rights for this"
        redirect_to root_path
      end
    end
end
