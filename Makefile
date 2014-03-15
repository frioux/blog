clean:
	rm public/* -rf

build: clean
	hugo

commit: build
	cd public; git add -A .; git ci -m 'derp'

push: commit
	cd public; git push origin HEAD:up -f
