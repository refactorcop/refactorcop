LINKS=--link rcop-db:db --link rcop-redis:redis
PORTS=-p 8080:3000
DEV_PORTS=-p 4000:3000
APP_IMAGE="rcop-app"
APP_CONTAINER="rcop-web"
DBDATA_CONTAINER="rcop-dbdata"
DB_IMAGE="postgres:9.3"
REDIS_IMAGE="redis:2.8"
DEV_DB_URL=postgresql://db:5432/rcop_development?pool=5&user=postgres

all: development

production:
	docker run -d \
		--name $(APP_CONTAINER) \
		$(LINKS) \
		$(PORTS) \
		--env-file .envfile \
		$(APP_IMAGE)

run-app:
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
		-e "DATABASE_URL=$(DEV_DB_URL)" \
		$(APP_IMAGE)

debug-app:
	docker run -i -t \
		--rm \
		-v `pwd`/:/refactorcop \
		$(LINKS) \
		$(DEV_PORTS) \
		-e "DATABASE_URL=$(DEV_DB_URL)" \
		--entrypoint "/bin/bash" \
		$(APP_IMAGE)

clean-app:
	docker stop $(APP_CONTAINER); docker rm $(APP_CONTAINER)

build-app:
	docker build -t $(APP_IMAGE) .

clean-setup: clean-db clean-redis

setup: run-db run-redis

run-db: run-dbdata setup-db

run-dbdata:
	docker run -d \
		--name $(DBDATA_CONTAINER) \
		--entrypoint /bin/echo \
		$(DB_IMAGE) Data-only container

setup-db:
	docker run -d --name "rcop-db" \
		--volumes-from $(DBDATA_CONTAINER) \
		$(DB_IMAGE)

clean-db:
	docker stop "rcop-db"; docker rm "rcop-db"

run-redis:
	docker run -d --name "rcop-redis" $(REDIS_IMAGE)

clean-redis:
	docker stop "rcop-redis"; docker rm "rcop-redis"
