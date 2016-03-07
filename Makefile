.PHONY: clean build push watch-server

watch-server:
	hugo server --bind=0.0.0.0 --watch

clean:
	rm public/* -rf

build: clean
	hugo

push: build
	git push
	cd public && ../bin/s3cmd sync /pwd/ s3://blog.afoolishmanifesto.com
