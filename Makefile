builder-image:
	echo "Building UBI7"
	docker build . -f jbs-ubi7-builder/Dockerfile -t quay.io/$(QUAY_USERNAME)/jbs-ubi7-builder:dev
	docker push quay.io/$(QUAY_USERNAME)/jbs-ubi7-builder:dev
	echo "Building UBI8"
	docker build . -f jbs-ubi8-builder/Dockerfile -t quay.io/$(QUAY_USERNAME)/jbs-ubi8-builder:dev
	docker push quay.io/$(QUAY_USERNAME)/jbs-ubi8-builder:dev
