IMAGE_NAME = knighttools/docker-tailscale-derp
TAG = v1.0.0
PLATFORMS = linux/amd64,linux/arm64

.PHONY: build push release

up:
	docker compose up -d

buildup:
	docker compose --file docker-compose.yaml --file docker-compose.override.yaml up -d --build

down:
	docker compose down

down:
	docker compose down

logs:
	docker compose logs -f

# 本地构建(只构建当前架构，不推送)
build:
	docker build -t $(IMAGE_NAME):$(TAG) .

# 多架构构建并推送到 Docker Hub (同时推送版本标签和 latest)
push:
	docker buildx build \
		--platform $(PLATFORMS) \
		-t $(IMAGE_NAME):$(TAG) \
		-t $(IMAGE_NAME):latest \
		--push .

# 一键发布
release: push
	@echo "✅ 已发布 $(IMAGE_NAME):$(TAG) 和 $(IMAGE_NAME):latest 到 Docker Hub (支持 $(PLATFORMS))"
