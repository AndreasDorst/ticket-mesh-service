class UsersController < ApplicationController
    def register
      user = User.new(user_params)
      
      if user.save
        # Генерируем токен для сессии
        # Это пример, для реального приложения можно использовать более сложный метод
        session_token = SecureRandom.hex(16)
        
        # Возвращаем ответ с user_id и session_token
        render json: { user_id: user.id, session_token: session_token }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def login
      user = User.find_by(document_number: params[:document_number])
      
      if user&.authenticate(params[:password])
        session_token = SecureRandom.hex(16)
        
        render json: { user_id: user.id, session_token: session_token }, status: :ok
      else
        render json: { errors: ['Неверный номер документа или пароль'] }, status: :unauthorized
      end
    end

    def logout
      # В реальном приложении можно удалить сессионный токен или пометить его как неактивный
      # Пока-что заглушка
      render json: { success: true }, status: :ok
    end

    private

    def user_params
      params.permit(:full_name, :age, :document_type, :document_number, :password, :password_confirmation)
    end
end
