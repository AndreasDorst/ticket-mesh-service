class User < ApplicationRecord
  has_secure_password

  validate :age_should_be_at_least_13
  validates :document_number, uniqueness: true
  private

  # Проверка на возраст
  def age_should_be_at_least_13
    return if age.nil? || age >= 13

    errors.add(:age, 'должен быть не менее 13 лет')
  end
end
