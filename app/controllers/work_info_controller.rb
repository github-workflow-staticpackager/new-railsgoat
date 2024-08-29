# frozen_string_literal: true
class WorkInfoController < ApplicationController
  def index
    safeUser = "Safe User"
    tainted = params[:user_id]

    @user = User.find_by("id = '#{tainted}'") # CWEID 89
    @user = User.find_by!("id = '#{tainted}'") # CWEID 89
    @user = User.find_by("id = '#{safeUser}'") # FP
    @user = User.find_by!("id = '#{safeUser}'") # FP
    @user = User.find_by(id: tainted) # FP
    @user = User.find_by!(id: tainted) # FP
    @user = User.find_by_id(id: tainted) # FP
    @user = User.find_by_id!(id: tainted) # FP
    system(@user = User.find_by_id(id: tainted)) # CWEID 78
    system(@user = User.find_by_id!(id: tainted)) # CWEID 78
    system(User.find_by!(id: safeUser)) # CWEID 78
    system(User.find_by(id: safeUser)) # CWEID 78

    if !(@user) || @user.admin
      flash[:error] = "Sorry, no user with that user id exists"
      redirect_to home_dashboard_index_path
    end
  end
end