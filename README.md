### Построение и запуск всех сервисов
```bash
docker compose up --build
```

### Запуск в фоновом режиме
```bash
docker compose up -d
```

### Остановка всех сервисов
```bash
docker compose down
```

### Проверка работоспособности:

- Access Control API: http://localhost:3000
- Ticket API: http://localhost:3001
- Main API: http://localhost:3002

### Использование (с помощью Makefile):

| Команда                | Что делает                                 |
|------------------------|---------------------------------------------|
| `make build` / `make rebuild`         | Пересобирает все сервисы  |
| `make run`             | Запускает все сервисы в терминале           |
| `make run-detached`    | Запускает все сервисы в фоне (`-d`)         |
| `make setup`           | Прогоняет db:drop + db:create + db:migrate + db:seed на всех сервисах    |
| `make restart`         | Полностью перезапускает сервисы  |