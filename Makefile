ADDONS := $(patsubst %-dev/config.yaml,%,$(wildcard *-dev/config.yaml))
DEV    := $(ADDON)-dev

SOURCE_REPO = $(shell sed -n 's/^url: "\(.*\)"/\1/p' $(DEV)/config.yaml)
SHA        ?= $(shell git ls-remote $(SOURCE_REPO) refs/heads/dev | cut -c1-7)

.DEFAULT_GOAL := help
.PHONY: help status dev-bump release check-addon

help: ## Show targets and the release flow
	@echo "Each addon has a dev twin (<addon>-dev/) that tracks the dev branch of its source repo."
	@echo "Work on <addon>-dev/ only; <addon>/ changes through 'make release'."
	@echo
	@echo "Release flow:"
	@echo "  1. Note changes in <addon>-dev/CHANGELOG.md under '## <version>'."
	@echo "  2. In the source repo: make release"
	@echo "  3. Here:               make release ADDON=<addon> VERSION=<version>"
	@echo "  4. git push"
	@echo
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-15s %s\n", $$1, $$2}'
	@echo
	@echo "All targets except help need ADDON=<addon>. Addons: $(ADDONS)"

check-addon:
	@test -n "$(filter $(ADDON),$(ADDONS))" || { echo "pass ADDON=<addon>, one of: $(ADDONS)"; exit 1; }

status: check-addon ## Show stable and dev versions of ADDON
	@echo "$(ADDON):  $$(sed -n 's/^version: "\(.*\)"/\1/p' $(ADDON)/config.yaml)"
	@echo "$(DEV): $$(sed -n 's/^version: "\(.*\)"/\1/p' $(DEV)/config.yaml) (dev branch of source repo at $(SHA))"

dev-bump: check-addon ## Point ADDON-dev at the dev-<sha> image (default: tip of the source repo's dev branch)
	@test -n "$(SHA)" || { echo "no dev branch found in $(SOURCE_REPO), pass SHA=<sha>"; exit 1; }
	scripts/check-image.sh $(DEV) dev-$(SHA)
	sed 's/^version: .*/version: "dev-$(SHA)"/' $(DEV)/config.yaml > $(DEV)/config.yaml.new
	mv $(DEV)/config.yaml.new $(DEV)/config.yaml
	git add $(DEV)/config.yaml
	git diff --cached --quiet || git commit -m "chore($(DEV)): point at dev-$(SHA)"

release: check-addon ## Copy ADDON-dev to ADDON as VERSION and commit (needs changelog entry and release image)
	@echo '$(VERSION)' | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$$' || { echo "usage: make release ADDON=<addon> VERSION=x.y.z"; exit 1; }
	@test "$$(git rev-parse --abbrev-ref HEAD)" = main || { echo "make release runs on main"; exit 1; }
	@test -z "$$(git status --porcelain)" || { echo "working tree not clean"; exit 1; }
	git pull --ff-only
	scripts/check-changelog.sh $(DEV)/CHANGELOG.md $(VERSION)
	scripts/check-image.sh $(DEV) $(VERSION)
	@name=$$(grep '^name:' $(ADDON)/config.yaml); slug=$$(grep '^slug:' $(ADDON)/config.yaml); \
	rm -rf $(ADDON).new && cp -R $(DEV) $(ADDON).new && \
	sed -e "s/^name: .*/$$name/" -e "s/^slug: .*/$$slug/" -e 's/^version: .*/version: "$(VERSION)"/' \
		-e '/^stage: /d' -e '/^advanced: /d' $(DEV)/config.yaml > $(ADDON).new/config.yaml && \
	rm -rf $(ADDON) && mv $(ADDON).new $(ADDON)
	git add -A $(ADDON)
	git commit -m "chore($(ADDON)): release $(VERSION)"
	@echo
	@git show --stat HEAD
	@echo
	@echo "Check the commit, then: git push"
