# 🎟️ Ticketing Microservices App

## 🔧 Настройка окружения

Прежде чем начать использовать проект, необходимо создать файл `.env` на основе примера:

```bash
# В корне проекта
cp .env.example .env

# Для access-control-api
cp access-control-api/.env.example access-control-api/.env
```

---

Проект состоит из трёх микросервисов:

- **Main API** (`localhost:3002`) — управление пользователями  
- **Ticket API** (`localhost:3001`) — события, билеты, покупки  
- **Access Control API** (`localhost:3000`) — проход на мероприятие, логирование входов/выходов

---

# 🚀 Быстрый старт

## 🛠️ Использование с помощью Makefile

| Команда             | Описание                                                                                    |
|---------------------|---------------------------------------------------------------------------------------------|
| `make init`   | 🔧 Полный билд всех контейнеров + настройка всех БД (build + setup) |
| `make build` / `make rebuild` | Пересобирает все сервисы  |
| `make up` | Запускает все сервисы в терминале |
| `make up-detached`/ `make up-d`   | Запускает все сервисы в фоне (`-d`)   |
| `make down`   | Останавливает все контейнеры и удаляет `orphan`-контейнеры    |
| `make restart`    | Полный перезапуск: выключение + запуск    |
| `make setup`  | Выполняет db: `drop`, `create`, `migrate`, `seed` для всех сервисов   |
| `make ticket-api-db`  | Запускает setup только для `ticket-api`  |
| `make main-api-db`    | Запускает setup только для `main-api`    |
| `make access-control-db`  | Запускает setup только для `access-control`  |
| `make tests`  | Выполняет все тесты  |
| `make integration-tests`  | Выполняет только интеграционные тесты (⚠️ сервисы должны быть при этом запущены)  |
| `make unit-tests`  | Выполняет только unit-тесты  |

## Использование (без Makefile)

### Построение и запуск всех сервисов
```bash
docker-compose up --build
```

### Запуск в фоновом режиме
```bash
docker-compose up -d
```

### Остановка всех сервисов
```bash
docker-compose down
```

---

## ✅ Проверка работоспособности

| Сервис              | URL                     |
|---------------------|--------------------------|
| Access Control API  | http://localhost:3000    |
| Ticket API          | http://localhost:3001    |
| Main API            | http://localhost:3002    |

---

## 📚 Документация API

Каждый микросервис предоставляет свой набор HTTP-эндпоинтов.

➡️ **Подробное описание всех доступных API-команд и примеров запросов находится в отдельном файле:**  
[`docs/api.md`](docs/api.md)

Там вы найдете:

- 🔐 Авторизацию и регистрацию пользователей, а также создание мероприятий в Main API  
- 🎟 Получение и покупку билетов в Ticket API  
- 🚪 Проверку доступа и логи входа/выхода в Access Control API  

---

## 📦 Зависимости

- Docker + Docker Compose
- Ruby on Rails (в контейнерах)
- PostgreSQL (поднимается внутри Docker)