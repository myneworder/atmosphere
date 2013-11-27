module Api
  module V1
    class UsersController < ApplicationController
      load_and_authorize_resource :user
      respond_to :json

      def index
        respond_with @users.order(:id)
      end

      def show
        respond_with @user
      end
    end
  end
end