#-------------------------------------------------------------------------------
# Running `make` will show the list of subcommands that will run.

all: help

.PHONY: help
## help: prints this help message
help:
	@echo "Usage: \n"
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'

#-------------------------------------------------------------------------------
# Dependencies

.PHONY: npm
## npm: [deps] installs all of the npm dependencies for the project
npm:
	npm install && npm audit fix

#-------------------------------------------------------------------------------
# Clean

.PHONY: clean
## clean-npm: [clean] removes the root `node_modules` directory
clean-npm:
	- rm -Rf ./node_modules

.PHONY: clean
## clean: [clean] runs ALL non-Docker cleaning tasks
clean: clean-npm

#-------------------------------------------------------------------------------
# Linting

.PHONY: markdownlint
## markdownlint: [lint] runs `markdownlint` (formatting, spelling) against all Markdown (*.md) documents with a standardized set of rules
markdownlint:
	@ echo " "
	@ echo "=====> Running Markdownlint..."
	npx markdownlint --fix '*.md' --ignore 'node_modules'

.PHONY: lint
## lint: [lint] runs ALL linting/validation tasks
lint: markdownlint

#-------------------------------------------------------------------------------
# Git Tasks

.PHONY: tag
## tag: [release] tags (and GPG-signs) the release
tag:
	@ if [ $$(git status -s -uall | wc -l) != 1 ]; then echo 'ERROR: Git workspace must be clean.'; exit 1; fi;

	@echo "This release will be tagged as: $$(cat ./VERSION)"
	@echo "This version should match your release. If it doesn't, re-run 'make version'."
	@echo "---------------------------------------------------------------------"
	@read -p "Press any key to continue, or press Control+C to cancel. " x;

	@echo " "
	@chag update $$(cat ./VERSION)
	@echo " "

	@echo "These are the contents of the CHANGELOG for this release. Are these correct?"
	@echo "---------------------------------------------------------------------"
	@chag contents
	@echo "---------------------------------------------------------------------"
	@echo "Are these release notes correct? If not, cancel and update CHANGELOG.md."
	@read -p "Press any key to continue, or press Control+C to cancel. " x;

	@echo " "

	git add .
	git commit -a -m "Preparing the $$(cat ./VERSION) release."
	chag tag --sign

.PHONY: version
## version: [release] sets the version for the next release; pre-req for a release tag
version:
	@echo "Current version: $$(cat ./VERSION)"
	@read -p "Enter new version number: " nv; \
	printf "$$nv" > ./VERSION
