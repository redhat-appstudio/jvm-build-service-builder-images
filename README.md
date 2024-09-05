# JVM Build Service Builder Images

This repo contains the builder images used to rebuild JVM based dependencies buy the JVM Build Service.

At present this consists of two images:

 * jbs-ubi7-builder
 * jbs-ubi8-builder

## Updating Images

In order to update the Dockerfiles in jbs-ubi7-builder / jbs-ubi8-builder do *not* update them directly but modify the `Dockerfile.template` and then run `generate.sh`.

To update versions (e.g. for Maven/Gradle/Ant) add or modify the versions in `image-config.yaml` and then add the appropriate version/SHA256 to `generate.sh`. For Ant, the versions are also referenced with the main jvm-build-service repository.

Once the image has been successfully updated and the PR merged then this should then be updated in the main jvm-build-service repository by modifying:
* deploy/operator/config/kustomization.yaml
* deploy/operator/config/system-config.yaml
