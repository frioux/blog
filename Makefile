clean:
	rm public/* -rf

build: clean
	hugo

commit: build
	cd public && git add -A . && git ci -m 'derp'

push: commit public
	cd public && git push origin HEAD:up -f

public:
	git init public && cd public && git remote add origin rss.afoolishmanifesto.com:/var/www/blog/repo

watch-server:
	hugo server --watch
