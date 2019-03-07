docker: ## Build and run docker container
	@echo "Building docker image"
	@docker build -t zyn-fusion .
	@echo "Granting root user access to Local X Server"
	@xhost local:root
	@echo "Running zyn-fusion container"
	@docker run -it \
		--net=host \
		-e DISPLAY \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		--device /dev/dri \
		--device /dev/snd \
		zyn-fusion

.PHONY: help

help: ## This help
		@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


