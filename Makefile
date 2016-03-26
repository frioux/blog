.PHONY: clean build push watch-server

watch-server:
	hugo server --bind=0.0.0.0 --watch

clean:
	rm public/* -rf

build: clean
	hugo

push: build
	git push
	cd public && ../bin/s3cmd sync --delete-removed --disable-multipart /pwd/ s3://blog.afoolishmanifesto.com && ../bin/s3cmd sync --add-header=x-amz-website-redirect-location:/index.xml /pwd/feed/index.html s3://blog.afoolishmanifesto.com/feed/index.html
