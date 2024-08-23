class SessionsController < ApplicationController
  def new

  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)

    if user && user.authenticate(params[:session][:password])
      session[:user_id] = user.id
      Rails.logger.info "Session for user #{user.username} created"
      session[:id] = generate_unique_session_id
      Rails.logger.info "Unique session id created: #{session[:id]}"
      Rails.cache.write("authorisation_for_FetchTokensDataJob_for_session_#{session[:id]}_user_#{user.id}", true)
      Rails.logger.info "Authorisation for FetchTokensDataJob for session #{session[:id]}; user #{user.id} approved"
      FetchTokensDataJob.perform_later(session[:id], user.id)
      wallet_ids = user.wallets.pluck(:id)

      if wallet_ids.count > 0
        wallet_ids.each do |wallet_id|
          Rails.cache.write("authorisation_for_FetchTokensDataJob_for_session_#{session[:id]}_user_#{user.id}_wallet_#{wallet_id}", true)
          Rails.logger.info "Authorisation for FetchTokensDataJob for session #{session[:id]}; user #{user.id}; wallet #{wallet_id} approved"
          FetchTokensDataJob.perform_later(session[:id], user.id, wallet_id)
        end
      end

      #Rails.logger.info "current_session: #{current_session.id}"
      #Rails.logger.info "current_session: #{current_session[:id]}"

      flash[:success] = "You're logged in!"
      redirect_to user_path(user)
    else
      flash[:danger] = "Invalid email or password!"
      render "new", status: :unprocessable_entity
    end
  end

  def destroy
    user_id = session[:user_id]
    wallet_ids = User.find(user_id).wallets.pluck(:id)
    Rails.logger.info "User #{user_id} wallets: #{wallet_ids}"
    Rails.cache.delete("authorisation_for_FetchTokensDataJob_for_session_#{session[:id]}_user_#{user_id}")
    Rails.logger.info "Authorisation for FetchTokensDataJob for session #{session[:id]}; user #{user_id} cancelled"

    if wallet_ids
      wallet_ids.each do |wallet_id|
        Rails.cache.delete("authorisation_for_FetchTokensDataJob_for_session_#{session[:id]}_user_#{user_id}_wallet_#{wallet_id}")
        Rails.logger.info "Authorisation for FetchTokensDataJob for session #{session[:id]}; user #{user_id}; wallet #{wallet_id} cancelled"
      end
    end

    session.delete(:id)
    Rails.logger.info "Session id deleted"
    session[:user_id] = nil
    Rails.logger.info "Session for user #{user_id} deleted"
    flash[:success] = "You're logged out!"
    redirect_to root_path
  end

  private
    def generate_unique_session_id
      SecureRandom.uuid
    end
end
