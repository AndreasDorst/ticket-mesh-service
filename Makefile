.PHONY: setup ticket-api main-api access-control run run-detached rebuild

# Полный сетап всех сервисов
setup: ticket-api main-api access-control

ticket-api:
	@echo "📦 Setting up ticket-api..."
	docker-compose run --rm ticket-api rails db:drop db:create db:migrate db:seed

main-api:
	@echo "📦 Setting up main-api..."
	docker-compose run --rm main-api rails db:drop db:create db:migrate db:seed

access-control:
	@echo "📦 Setting up access-control..."
	docker-compose run --rm access-control rails db:drop db:create db:migrate db:seed

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
