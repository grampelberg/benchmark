
.PHONY: serve
serve:
	gunicorn \
		-w 1 \
		-k uvicorn.workers.UvicornWorker \
		-b :8080 \
		-e DEV=true \
		-e PORT=6379 \
		--reload \
		sink.app:app

.PHONY: run
run:
	docker-compose -f $(ROOT_DIR)/compose/base.yml up \
		-d \
		--build

.PHONY: sh
sh:
	docker exec -it frontend /bin/sh

.PHONY: dev
dev:
	docker-compose \
		-f $(ROOT_DIR)/compose/base.yml \
		-f $(ROOT_DIR)/compose/dev.yml up \
		-d \
		--build
	-docker exec -it sink /bin/sh
	$(MAKE) down

.PHONY: build
build:
	docker-compose -f $(ROOT_DIR)/compose/base.yml build

.PHONY: push
push: build
	docker push thomasr/benchmark-sink:v1

.PHONY: logs
logs:
	docker-compose \
		-f $(ROOT_DIR)/compose/base.yml \
		-f $(ROOT_DIR)/compose/dev.yml \
		logs -f

.PHONY: down
down:
	docker-compose -f $(ROOT_DIR)/compose/base.yml down

.PHONY: update-lock
update-lock:
	rm $(ROOT_DIR)/requirements.txt
	pip-compile --output-file $(ROOT_DIR)/requirements.txt \
		$(ROOT_DIR)/requirements.in
