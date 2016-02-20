.PHONY: clean build push watch-server

watch-server:
	hugo server --bind=0.0.0.0 --watch

clean:
	rm public/* -rf

build: clean
	hugo

push: build
	git push
	cd public && aws s3 sync --delete /pwd/ s3://blog.afoolishmanifesto.com
