# ===== Artifact Variables =====
# Get the current date in YYYYMMDD format
DATE := $(shell date +%Y%m%d)
ZIP_NAME_PREFIX := flatcar-deployment-package
ZIP_NAME := $(ZIP_NAME_PREFIX)-$(DATE).zip

define fetch_flatcar_version
$(shell sh -c 'curl -fsSL https://$1.release.flatcar-linux.net/amd64-usr/current/version.txt \
  | sed -n "s/^FLATCAR_VERSION=//p"')
endef

STABLE_VERSION = $(call fetch_flatcar_version,stable)
BETA_VERSION   = $(call fetch_flatcar_version,beta)
ALPHA_VERSION  = $(call fetch_flatcar_version,alpha)

# ===== Convert the version number to dashed =====
dot_to_dash = $(subst .,-,$(1))
export STABLE_VERSION_DASHED := $(call dot_to_dash,$(STABLE_VERSION))
export BETA_VERSION_DASHED   := $(call dot_to_dash,$(BETA_VERSION))
export ALPHA_VERSION_DASHED  := $(call dot_to_dash,$(ALPHA_VERSION))

# ===== Paths =====
OUTPUTS := metadata.display.yaml metadata.yaml main.tf variables.tf

# ===== Default =====
all: package upload update-git

# check if version have been fetched properly.
# FIXME: handle multiple channel failures
check-versions:
	@test -n "$(STABLE_VERSION)" || (echo "Error: STABLE_VERSION is empty (fetch failed?). Pass STABLE_VERSION explicitly"; exit 1)
	@test -n "$(BETA_VERSION)"   || (echo "Error: BETA_VERSION is empty (fetch failed?). Pass BETA_VERSION explicitly"; exit 1)
	@test -n "$(ALPHA_VERSION)"  || (echo "Error: ALPHA_VERSION is empty (fetch failed?). Pass ALPHA_VERSION explicitly"; exit 1)

$(OUTPUTS): %: %.in | check-versions
	envsubst '$$STABLE_VERSION_DASHED $$BETA_VERSION_DASHED $$ALPHA_VERSION_DASHED' < $< > $@

# create the zip to upload to GCP
package: $(ZIP_NAME)
$(ZIP_NAME): $(OUTPUTS) LICENSE README.md
	rm -f -- $@
	zip -r $@ $^ >/dev/null 2>&1 || true
	@echo "Created: $@"

upload: $(ZIP_NAME)
	@command -v gsutil >/dev/null 2>&1 || { echo "Error: gsutil not found in PATH"; exit 1; }
	gsutil cp "$<" gs://flatcar-marketplace/deployments

update-git: $(OUTPUTS)
	git checkout -b release-$(DATE)
	git add $(OUTPUTS)
	git commit -m "Release $(DATE)" -s
	git push origin release-$(DATE)
	@echo "Updated terrforms files in $(BRANCH) has been pushed to remote"
	git checkout -

# Clean target to remove the zip file
clean:
	rm -rf $(ZIP_NAME_PREFIX)-*.zip

show:
	@echo "Stable: $(STABLE_VERSION) -> $(STABLE_VERSION_DASHED)"
	@echo "Beta:   $(BETA_VERSION)   -> $(BETA_VERSION_DASHED)"
	@echo "Alpha:  $(ALPHA_VERSION)  -> $(ALPHA_VERSION_DASHED)"

.PHONY: all package upload clean show check-versions update-git
