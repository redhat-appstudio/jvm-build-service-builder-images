builder-image:
	docker build . -f hacbs-jdk7-builder/Dockerfile -t quay.io/$(QUAY_USERNAME)/hacbs-jdk7-builder:dev
	docker push quay.io/$(QUAY_USERNAME)/hacbs-jdk7-builder:dev
	docker build . -f hacbs-jdk17-builder/Dockerfile -t quay.io/$(QUAY_USERNAME)/hacbs-jdk17-builder:dev
	docker push quay.io/$(QUAY_USERNAME)/hacbs-jdk17-builder:dev
