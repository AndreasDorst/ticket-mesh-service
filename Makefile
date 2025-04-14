.PHONY: setup ticket-api main-api access-control run run-detached rebuild db-drop db-create db-migrate db-seed

# Полный сетап всех сервисов
setup: ticket-api-db db-drop db-create db-migrate db-seed

ticket-api-db:
	@echo "📦 Setting up ticket-api..."
	docker-compose run --rm ticket-api rails db:drop db:create db:migrate db:seed

main-api-db:
	@echo "📦 Setting up main-api..."
	docker-compose run --rm main-api rails db:drop db:create db:migrate db:seed

access-control-db:
	@echo "📦 Setting up access-control..."
	docker-compose run --rm access-control rails db:drop db:create db:migrate db:seed

# Команды для работы с базой данных для каждого сервиса
db-drop:
	@echo "📦 Dropping databases..."
	docker-compose run --rm ticket-api rails db:drop
	docker-compose run --rm main-api rails db:drop
	docker-compose run --rm access-control rails db:drop

db-create:
	@echo "📦 Creating databases..."
	docker-compose run --rm ticket-api rails db:create
	docker-compose run --rm main-api rails db:create
	docker-compose run --rm access-control rails db:create

db-migrate:
	@echo "📦 Running database migrations..."
	docker-compose run --rm ticket-api rails db:migrate
	docker-compose run --rm main-api rails db:migrate
	docker-compose run --rm access-control rails db:migrate

db-seed:
	@echo "📦 Seeding databases..."
	docker-compose run --rm ticket-api rails db:seed
	docker-compose run --rm main-api rails db:seed
	docker-compose run --rm access-control rails db:seed

# Запустить все сервисы
run:
	docker-compose up

# Запустить все сервисы в фоне
run-detached:
	docker-compose up -d

build:
	docker-compose build

rebuild: build

# Рестарт всех контейнеров
restart:
	docker-compose down --remove-orphans
	docker-compose up
