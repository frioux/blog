.PHONY: clean build push watch-server
export PATH := $(shell pwd)/bin:$(PATH)

watch-server:
	hugo server --bind=0.0.0.0 --watch

clean:
	test -z "$(shell git status --porcelain)" || ( echo 'uncommited changes!'; exit 1)
	rm public/* -rf

build: clean
	bin/check-guids && hugo

push: build
	git push
	cd public && s3cmd sync --delete-removed --disable-multipart --no-preserve /pwd/ s3://blog.afoolishmanifesto.com | tee ../s3cmd.log && set-redirects && . ~/.cf-token && busted-urls ../s3cmd.log && rm ../s3cd.log
