class UsersController < ApplicationController
before_action :require_login
before_action :find_correct_user, only: [ :edit, :update ]
before_action :not_login_user, only: [ :new, :create ]
before_action :find_user, only: [ :user_songs, :favorite_songs, :recent_comments ]
skip_before_action :require_login, :only => [ :index, :new, :show, :create, :activate ]

  def show
    @user = User.find_by_name(params[:id])
    @songs = @user.songs.order("created_at desc")
  end

  def new
  	@user = User.new
  end

  def create
  	@user = User.new(user_params)
  	if @user.save
  	  flash[:success] = "注册成功"
        respond_to do |format|
          format.html { redirect_to root_path }
          format.js
        end
  	else
        respond_to do |format|
          format.html { render 'new' }
          format.js
        end
  	end
  end

  def edit
  end

  def update
    if @user.update_attributes(update_user_params)
      flash[:success] = "保存成功"
      respond_to do |format|
        format.html { redirect_to root_path }
        format.js
      end
    else
      flash.now[:error] = "保存失败"
      respond_to do |format|
        format.html { render 'edit' }
        format.js
      end
    end
  end

  def activate
    if (@user = User.load_from_activation_token(params[:id]))
      @user.activate!
      flash[:success] = "激活成功"
      redirect_to login_path
    else
      not_authenticated
    end
  end

  def user_songs
    @songs = @user.songs.order("created_at desc")
  end

  def favorite_songs
    songs_id = @user.likeships.where("likeable_type = ?", "Song").collect(&:likeable_id)
    @songs = Song.find(songs_id).reverse!

    respond_to do |format|
      format.js
    end
  end

  def recent_comments
    @comments = @user.comments.order("created_at desc")
    respond_to do |format|
      format.js
    end
  end

  private

  def find_correct_user
    @user = User.find_by_name(params[:id])
    unless current_user?(@user)
      flash[:warning] = "无权访问"
      redirect_to root_path
    end
  end

  def find_user
    @user = User.find_by_name(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)   
  end

  def update_user_params
    params.require(:user).permit(:bio, :avatar, :password, :password_confirmation)
  end

  def not_login_user
    if logged_in?
      redirect_to root_path
      flash[:warning] = "你已经登录"
    end
  end
end
