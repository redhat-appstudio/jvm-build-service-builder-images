

builder-image:
	docker build . -f ./builder-images/hacbs-jdk8-builder/Dockerfile -t quay.io/$(QUAY_USERNAME)/hacbs-jdk8-builder:dev
	docker push quay.io/$(QUAY_USERNAME)/hacbs-jdk8-builder:dev
	docker build . -f ./builder-images/hacbs-jdk11-builder/Dockerfile -t quay.io/$(QUAY_USERNAME)/hacbs-jdk11-builder:dev
	docker push quay.io/$(QUAY_USERNAME)/hacbs-jdk11-builder:dev
	docker build . -f ./builder-images/hacbs-jdk17-builder/Dockerfile -t quay.io/$(QUAY_USERNAME)/hacbs-jdk17-builder:dev
	docker push quay.io/$(QUAY_USERNAME)/hacbs-jdk17-builder:dev

