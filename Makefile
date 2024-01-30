builder-image:
	echo "Building UBI7"
	docker build . -f hacbs-ubi7-builder/Dockerfile -t quay.io/$(QUAY_USERNAME)/hacbs-ubi7-builder:dev
	docker push quay.io/$(QUAY_USERNAME)/hacbs-ubi7-builder:dev
	echo "Building UBI8"
	docker build . -f hacbs-ubi8-builder/Dockerfile -t quay.io/$(QUAY_USERNAME)/hacbs-ubi8-builder:dev
	docker push quay.io/$(QUAY_USERNAME)/hacbs-ubi8-builder:dev
