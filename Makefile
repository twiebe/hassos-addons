ADDON ?= vector
DEV   := $(ADDON)-dev

SOURCE_REPO := $(shell sed -n 's/^url: "\(.*\)"/\1/p' $(DEV)/config.yaml)
SHA         ?= $(shell git ls-remote $(SOURCE_REPO) refs/heads/dev | cut -c1-7)

.DEFAULT_GOAL := help
.PHONY: help status dev-bump release

help: ## Show targets and the release flow
	@echo "Each addon has a dev twin (<addon>-dev/) that tracks the dev branch of its source repo."
	@echo "Work on <addon>-dev/ only; <addon>/ changes through 'make release'."
	@echo
	@echo "Release flow:"
	@echo "  1. Note changes in $(DEV)/CHANGELOG.md under '## <version>'."
	@echo "  2. In the source repo: make release"
	@echo "  3. Here:               make release VERSION=<version>"
	@echo "  4. git push"
	@echo
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-15s %s\n", $$1, $$2}'
	@echo
	@echo "Pick the addon with ADDON=<name> (default: vector)."

status: ## Show stable and dev versions of ADDON
	@echo "$(ADDON):  $$(sed -n 's/^version: "\(.*\)"/\1/p' $(ADDON)/config.yaml)"
	@echo "$(DEV): $$(sed -n 's/^version: "\(.*\)"/\1/p' $(DEV)/config.yaml) (dev branch of source repo at $(SHA))"

dev-bump: ## Point ADDON-dev at the dev-<sha> image (default: tip of the source repo's dev branch)
	@test -n "$(SHA)" || { echo "no dev branch found in $(SOURCE_REPO), pass SHA=<sha>"; exit 1; }
	scripts/check-image.sh $(DEV) dev-$(SHA)
	sed -i 's/^version: .*/version: "dev-$(SHA)"/' $(DEV)/config.yaml
	git add $(DEV)/config.yaml
	git diff --cached --quiet || git commit -m "chore($(DEV)): point at dev-$(SHA)"

release: ## Copy ADDON-dev to ADDON as VERSION and commit (needs changelog entry and release image)
	@echo '$(VERSION)' | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$$' || { echo "usage: make release VERSION=x.y.z"; exit 1; }
	@test "$$(git rev-parse --abbrev-ref HEAD)" = main || { echo "make release runs on main"; exit 1; }
	@test -z "$$(git status --porcelain)" || { echo "working tree not clean"; exit 1; }
	git pull --ff-only
	scripts/check-changelog.sh $(DEV)/CHANGELOG.md $(VERSION)
	scripts/check-image.sh $(DEV) $(VERSION)
	@name=$$(grep '^name:' $(ADDON)/config.yaml); slug=$$(grep '^slug:' $(ADDON)/config.yaml); \
	rm -rf $(ADDON) && cp -r $(DEV) $(ADDON) && \
	sed -i -e "s/^name: .*/$$name/" -e "s/^slug: .*/$$slug/" -e 's/^version: .*/version: "$(VERSION)"/' \
		-e '/^stage: /d' -e '/^advanced: /d' $(ADDON)/config.yaml
	git add -A $(ADDON)
	git commit -m "chore($(ADDON)): release $(VERSION)"
	@echo
	@git show --stat HEAD
	@echo
	@echo "Check the commit, then: git push"
