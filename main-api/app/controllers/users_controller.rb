class UsersController < ApplicationController
  # before_action :authenticate_user, only: [:get_user]

  def register
    user = User.new(user_params)

    if user.save
      session[:user_id] = user.id
      render json: { user_id: user.id }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(document_number: params[:document_number])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      render json: { success: true }, status: :ok
    else
      render json: { errors: ['Неверный номер документа или пароль'] }, status: :unauthorized
    end
  end

  def logout
    reset_session
    render json: { success: true }, status: :ok
  end

  def get_user
    user = User.find_by(id: params[:id])

    if user
      render json: {
        full_name: user.full_name,
        document_number: user.document_number
      }, status: :ok
    else
      render json: { error: 'Пользователь не найден' }, status: :not_found
    end
  end

  private

  def user_params
    params.permit(:full_name, :age, :document_type, :document_number, :password, :password_confirmation)
  end

  def authenticate_user
    @current_user = User.find_by(id: session[:user_id])

    unless @current_user
      render json: { error: 'Нужно войти' }, status: :unauthorized
    end
  end
end
