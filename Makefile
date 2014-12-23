LINKS=--link rcop-db:db --link rcop-redis:redis
PORTS=-p 8080:3000
DEV_PORTS=-p 4000:3000
APP_IMAGE="rcop-app"
APP_CONTAINER="rcop-web"
DB_IMAGE="postgres:9.3"
REDIS_IMAGE="redis:2.8"

production:
	docker run -d \
		--name $(APP_CONTAINER) \
		$(LINKS) \
		$(PORTS) \
		--env-file .envfile \
		$(APP_IMAGE)

docker-run-app:
	docker run -d \
		--name $(APP_CONTAINER) \
		$(LINKS) \
		$(PORTS) \
		$(APP_IMAGE)

development: build-app
	docker run -i -t \
		--rm \
		-v `pwd`/:/refactorcop \
		$(LINKS) \
		$(DEV_PORTS) \
		$(APP_IMAGE)

debug-app:
	docker run -i -t \
		--rm \
		-v `pwd`/:/refactorcop \
		$(LINKS) \
		$(DEV_PORTS) \
		--entrypoint "/bin/bash" \
		$(APP_IMAGE)

clean-app:
	docker stop $(APP_CONTAINER); docker rm $(APP_CONTAINER)

build-app:
	docker build -t $(APP_IMAGE) .

docker-run-db:
	docker run -d --name "rcop-db" \
		-v `pwd`/volumes/data:/var/lib/postgresql/data \
		$(DB_IMAGE)

docker-clean-db:
	docker stop "rcop-db"; docker rm "rcop-db"

docker-run-redis:
	docker run -d --name "rcop-redis" $(REDIS_IMAGE)
