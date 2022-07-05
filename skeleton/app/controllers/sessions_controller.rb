class SessionsController < ApplicationController

    before_action :require_logged_out, only: [:new, :create]
    before_action :require_logged_in, only: [:destroy]

    def new
        @user = User.new
        render :new
    end

    def create
        @user = User.find_by_credentials(params[:user][:user_name],params[:user][:password])

        session[:session_token] = @user.reset_session_token!

        redirect_to cats_url
    end

    def destroy
        logout!
        redirect_to new_session_url
    end
end