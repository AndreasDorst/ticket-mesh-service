# Access Control API

Система управления доступом в помещения с интеграцией внешнего сервиса билетов.

## Требования

- Ruby 3.0+
- Rails 7.0+
- PostgreSQL
- Redis (для Sidekiq)
- Доступ к сервису билетов

```
http://localhost:3000/api/v1
```

Метод	Путь	        Описание	      Параметры
POST	/access/entry	Попытка входа	  ticket_id, document_number
POST	/access/exit	Попытка выхода	ticket_id

POST /access/entry

1. Поиск билета по external_id
2. Проверка последней записи доступа
3. Валидация повторного входа
4. Проверка во внешнем сервисе
5. Создание записи входа

POST /access/exit

1. Поиск билета по external_id
2. Проверка последней записи доступа
3. Валидация наличия активного входа
4. Создание записи выхода

## Использование API

1. Попытка входа

Запрос:

```
curl -X POST http://localhost:3000/api/v1/access/entry \
  -H "Content-Type: application/json" \
  -d '{
    "ticket_id": 123,
    "document_number": "AB123456"
  }'
```

Успешный ответ (200):

```
{
  "access_granted": true,
  "log_id": 45
}
```

## Возможные ошибки:

- 404: Ticket not found
- 403: Invalid credentials
- 409: Already inside
- 503: Ticket service unavailable

## Запуск тестов

```
rspec spec/requests/access_logs_spec.rb
```