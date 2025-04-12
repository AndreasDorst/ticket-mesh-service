# Access Control API

Система управления доступом в помещения с интеграцией внешнего сервиса билетов.

## Требования

- Ruby 3.0+
- Rails 7.0+
- PostgreSQL
- Redis (для Sidekiq)
- Доступ к сервису билетов

## API Endpoints

```
http://localhost:3000/api/
```

| Метод | Путь             | Описание        | Параметры                    |
|-------|------------------|-----------------|------------------------------|
| POST  | /api/access/entry| Попытка входа   | ticket_id, document_number  |
| POST  | /api/access/exit | Попытка выхода  | ticket_id                   |

### POST /api/access/entry

1. Поиск билета по external_id
2. Если билет не найден:
   - Проверка во внешнем сервисе билетов
   - Создание нового билета при успешной валидации
3. Проверка последней записи доступа
4. Валидация повторного входа
5. Создание записи входа

### POST /api/access/exit

1. Поиск билета по external_id
2. Проверка последней записи доступа
3. Валидация наличия активного входа
4. Создание записи выхода

## Использование API

### Попытка входа

```bash
curl -X POST http://localhost:3000/api/access/entry \
  -H "Content-Type: application/json" \
  -d '{
    "ticket_id": 123,
    "document_number": "AB123456"
  }'
```

Успешный ответ (200):
```json
{
  "access_granted": true,
  "log_id": 45
}
```

### Попытка выхода

```bash
curl -X POST http://localhost:3000/api/access/exit \
  -H "Content-Type: application/json" \
  -d '{
    "ticket_id": 123
  }'
```

Успешный ответ (200):
```json
{
  "exit_registered": true,
  "log_id": 46
}
```

## Возможные ошибки

| Код | Описание                   | Причина                                    |
|-----|----------------------------|--------------------------------------------| 
| 404 | Ticket not found           | Билет не найден                            |
| 403 | Invalid credentials        | Неверные учетные данные                    |
| 409 | Already inside             | Попытка повторного входа                   |
| 409 | Not inside                 | Попытка выхода без предварительного входа  |
| 503 | Ticket service unavailable | Сервис билетов недоступен                  |

## Запуск тестов

```bash
RAILS_ENV=test rspec ./spec/requests/access_logs_spec.rb
```