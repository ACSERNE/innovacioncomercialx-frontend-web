.PHONY: build up down clean logs test lint

build:
	docker-compose build --parallel

up:
	docker-compose up -d --remove-orphans

down:
	docker-compose down --volumes --remove-orphans

clean:
	docker system prune -af
	docker volume prune -f

logs:
	docker-compose logs -f

test:
	cd frontend-web && npm ci && npm run test
