.PHONY: clean build push watch-server init
export PATH := $(shell pwd)/bin:$(PATH)

log = ../s3cmd.log

watch-server: init
	bin/hugo-0.49 server --bind=0.0.0.0 --watch

init:
	@if [ -x bin/hugo-0.49 ]; then \
		echo "hugo-0.49 already installed"; \
	else \
		echo "Installing hugo-0.49..."; \
		case $$(uname -s) in \
			Darwin) os=macOS;; \
			Linux)  os=Linux;; \
			*)      echo "Unsupported OS"; exit 1;; \
		esac; \
		curl -sSL "https://github.com/gohugoio/hugo/releases/download/v0.49/hugo_0.49_$${os}-64bit.tar.gz" -o /tmp/hugo-0.49.tgz; \
		tar xzf /tmp/hugo-0.49.tgz -C bin/ hugo; \
		mv bin/hugo bin/hugo-0.49; \
		rm -f /tmp/hugo-0.49.tgz; \
		echo "hugo-0.49 installed to bin/"; \
	fi
	@perl -e 'use DBI; use DBD::SQLite; use YAML::Syck' 2>/dev/null \
		&& echo "Perl modules OK" \
		|| echo "Missing Perl modules: DBI, DBD::SQLite, YAML::Syck (install via cpanm or your package manager)"

clean:
	test -z "$(shell git status --porcelain)" || ( echo 'uncommited changes!'; exit 1)
	rm public/* -rf

build: clean
	test -z "$(shell git grep -F ']()' '*.md')"
	bin/check-guids && bin/hugo-0.49 --quiet

push: build
	git push --quiet
	s3cmd sync --region us-west-2 --delete-removed --disable-multipart --no-preserve public/ s3://blog.afoolishmanifesto.com | tee $(log) && set-redirects && go run ./bin/busted-urls < $(log) && rm -f $(log)
