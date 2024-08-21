class SessionsController < ApplicationController
  def new

  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)

    if user && user.authenticate(params[:session][:password])
      flash[:success] = "You're logged in!"
      session[:user_id] = user.id

      # Trigger the job to start fetching tokens data
      FetchTokensDataJob.perform_later(user.id)
      Rails.cache.write("fetch_tokens_job_#{user.id}", true)

      Rails.logger.info "Logged in as #{user.username}"
      redirect_to user_path(user)
    else
      flash[:danger] = "Invalid email or password!"
      render "new", status: :unprocessable_entity
    end
  end

  def destroy
    user_id = session[:user_id]

    if user_id
      # Set the cache to indicate the job should stop running
      Rails.cache.write("fetch_tokens_job_#{user_id}", false)

      session[:user_id] = nil
      flash[:success] = "You're logged out!"
      Rails.logger.info "User #{user_id} logged out"
    end
    redirect_to root_path
  end
end
