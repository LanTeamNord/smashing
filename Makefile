NAME = smashing
VERSION = $(shell git describe --tags)
REGISTRY = 448220486850.dkr.ecr.eu-west-1.amazonaws.com

all: build

build:
	docker build -t $(NAME):$(VERSION) --rm .

test:
	@echo "*** NO TESTS DECLARED"

tag_latest:
	docker tag $(NAME):$(VERSION) $(NAME):latest

release: build test tag_latest
	@echo "Tagging container"
	docker tag $(NAME):latest $(REGISTRY)/$(NAME):$(VERSION)
	docker tag $(NAME):latest $(REGISTRY)/$(NAME):latest
	@echo "Pushing to docker registry, please be patient"
	docker push $(REGISTRY)/$(NAME):$(VERSION)
	docker push $(REGISTRY)/$(NAME):latest
	@echo "*** Don't forget to create a tag. git tag rel-$(VERSION) && git push origin rel-$(VERSION)"

clean:
ifneq ($(shell docker images -q $(NAME):latest),)
	docker rmi $(NAME):latest
endif
ifneq ($(shell docker images -q $(NAME):$(VERSION)),)
	docker rmi $(NAME):$(VERSION)
endif
ifneq ($(shell docker images -q $(REGISTRY)/$(NAME):latest),)
	docker rmi $(REGISTRY)/$(NAME):latest
endif
ifneq ($(shell docker images -q $(REGISTRY)/$(NAME):$(VERSION)),)
	docker rmi $(REGISTRY)/$(NAME):$(VERSION)
endif


.PHONY: all build test tag_latest release clean
