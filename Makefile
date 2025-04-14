.PHONY: setup ticket-api main-api access-control run run-detached rebuild db-drop db-create db-migrate db-seed

# Первоначальная установка всего проекта
init: build setup

# Установка баз данных всех сервисов
setup: ticket-api-db main-api-db access-control-db

# Сборка всех необходимых контейнеров
build:
	docker-compose build

ticket-api-db:
	@echo "📦 Setting up ticket-api..."
	docker-compose run --rm ticket-api rails db:drop db:create db:migrate db:seed

main-api-db:
	@echo "📦 Setting up main-api..."
	docker-compose run --rm main-api rails db:drop db:create db:migrate db:seed

access-control-db:
	@echo "📦 Setting up access-control..."
	docker-compose run --rm access-control rails db:drop db:create db:migrate db:seed

up:
	docker-compose up

up-detached:
	docker-compose up -d

up-d: up-detached

down:
	docker-compose down --remove-orphans

rebuild: build

restart:
	docker-compose down --remove-orphans
	docker-compose up