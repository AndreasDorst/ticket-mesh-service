### Построение и запуск всех сервисов
docker compose up --build

### Запуск в фоновом режиме
docker compose up -d

### Остановка всех сервисов
docker compose down

### Проверка работоспособности:

- Access Control API: http://localhost:3000
- Ticket API: http://localhost:3001
- Main API: http://localhost:3002