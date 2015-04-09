class UsersController < ApplicationController  
  before_action :logged_in_user,     only: [:index, :show, :edit, :update, :destroy]
  before_action :non_logged_in_user, only: [:new, :create]
  before_action :correct_user,       only: [:edit, :update]
  before_action :admin_user,         only: :destroy

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.friendly.find(params[:id])
    @page_name = "user_page"
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url      
    else
      render 'new'
    end
  end # create

  def destroy
    @user = User.find(params[:id])
    if ( current_user != @user )
      @user.destroy
      flash[:success] = "User deleted."
      redirect_to users_url
    else
      redirect_to @user, notice: "Suicide is not permitted, admin chappie. Hard cheese."
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end # update

  private

    def user_params
      params.require(:user).permit(:name, :email, :callsign, :password, :password_confirmation)
    end

    # Before filters

    def non_logged_in_user
      if logged_in?
        redirect_to root_url, notice: "Nice try pal. You can't create a new user 
                                       if you're already signed in."
      end
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end

end
