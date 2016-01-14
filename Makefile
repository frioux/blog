.PHONY: clean build commit push watch-server

watch-server:
	hugo server --bind=0.0.0.0 --watch

clean:
	rm public/* -rf

build: clean
	hugo

commit: build
	cd public
	git add -Af .
	git ci -m 'derp'

push: commit | public
	git push
	cd public && git push origin HEAD:up -f

public: | public/.git

public/.git:
	git init public
	cd public && git remote add origin rss.afoolishmanifesto.com:/var/www/blog/repo
