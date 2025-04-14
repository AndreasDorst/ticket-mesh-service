module UserHelper
  # Функция уже обрабатывает возврат всех ошибок, оборачивать ее не надо
  def get_user!(user_id)
    begin
      user = MainApi::UserFetcher.call(user_id)
      return user
    rescue MainApi::UserFetcher::NotFound
      error!({ error: 'User not found' }, 404)
    rescue MainApi::UserFetcher::ConnectionFailed => e
      error!({ error: 'Main API not reachable', details: e.message }, 503)
    rescue MainApi::UserFetcher::Error => e
      error!({ error: 'Failed to fetch user', details: e.message }, 502)
    end
  end
end
