PACKAGE      = github.com/snormore/perf
PACKAGE_NAME = perf
DATE        ?= $(shell date +%s)
VERSION     ?= $(shell cat $(CURDIR)/VERSION)
GIT_COMMIT   = $(shell git rev-parse HEAD)
PKGS         = $(or $(PKG),$(shell env GO111MODULE=on $(GO) list ./...))
TESTPKGS   	 = $(shell env GO111MODULE=on $(GO) list -f '{{ if or .TestGoFiles .XTestGoFiles }}{{ .ImportPath }}{{ end }}' $(PKGS))
BIN      	 = $(CURDIR)/bin
GO     	     = go
TIMEOUT      = 15
V 			 = 0
Q 			 = $(if $(filter 1,$V),,@)
M 			 = $(shell printf "\033[34;1m▶\033[0m")
DOCKER       = docker
DOCKER_OWNER = snormore

export GO111MODULE=on

.PHONY: all
all: build

build: build-client build-server

build-client-package: fmt lint $(BIN) ; $(info $(M) building executable...) @ ## Build program binary
	$Q $(GO) build \
		-ldflags '-X $(PACKAGE)/cmd.PackageName=$(PACKAGE_NAME) -X $(PACKAGE)/cmd.Version=$(VERSION) -X $(PACKAGE)/cmd.BuildTimestamp=$(DATE) -X $(PACKAGE)/cmd.GitCommit=$(GIT_COMMIT)' \
		-o $(BIN)/$(PACKAGE_NAME) main.go

build-client: ; $(info $(M) building client docker image...) @
	$Q $(DOCKER) build -t $(DOCKER_OWNER)/$(PACKAGE_NAME)-client -f docker/client/Dockerfile .

build-server: ; $(info $(M) building server docker image...) @
	$Q cd docker/server && $(DOCKER) build -t $(DOCKER_OWNER)/$(PACKAGE_NAME)-server .

run-client: SERVER_IP=$(shell docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(PACKAGE_NAME)-server)
run-client: build-client ; $(info $(M) running client docker image...) @
	@$(DOCKER) run --rm -e "SERVER_IP=$(SERVER_IP)" -e "HTTP_PORT=8000" -e "IPERF_PORT=5000" -it $(DOCKER_OWNER)/$(PACKAGE_NAME)-client $(ARGS)

run-server: build-server ; $(info $(M) building server docker image...) @
	@$(DOCKER) run --rm -it --name $(PACKAGE_NAME)-server -e "HTTP_PORT=8000" -e "IPERF_PORT=5000" $(DOCKER_OWNER)/$(PACKAGE_NAME)-server $(ARGS)

# Tools

$(BIN):
	@mkdir -p $@
$(BIN)/%: | $(BIN) ; $(info $(M) building $(REPOSITORY)...)
	$Q tmp=$$(mktemp -d); \
	   env GO111MODULE=off GOPATH=$$tmp GOBIN=$(BIN) $(GO) get $(REPOSITORY) \
		|| ret=$$?; \
	   rm -rf $$tmp ; exit $$ret

GOLINT = $(BIN)/golint
$(BIN)/golint: REPOSITORY=golang.org/x/lint/golint

GOCOVMERGE = $(BIN)/gocovmerge
$(BIN)/gocovmerge: REPOSITORY=github.com/wadey/gocovmerge

GOCOV = $(BIN)/gocov
$(BIN)/gocov: REPOSITORY=github.com/axw/gocov/...

GOCOVXML = $(BIN)/gocov-xml
$(BIN)/gocov-xml: REPOSITORY=github.com/AlekSi/gocov-xml

GO2XUNIT = $(BIN)/go2xunit
$(BIN)/go2xunit: REPOSITORY=github.com/tebeka/go2xunit

# Tests

TEST_TARGETS := test-default test-bench test-short test-verbose test-race
.PHONY: $(TEST_TARGETS) test-xml check test tests
test-bench:   ARGS=-run=__absolutelynothing__ -bench=. ## Run benchmarks
test-short:   ARGS=-short        ## Run only short tests
test-verbose: ARGS=-v            ## Run tests in verbose mode with coverage reporting
test-race:    ARGS=-race         ## Run tests with race detector
$(TEST_TARGETS): NAME=$(MAKECMDGOALS:test-%=%)
$(TEST_TARGETS): test
check test tests: fmt lint ; $(info $(M) running $(NAME:%=% )tests...) @ ## Run tests
	$Q $(GO) test -timeout $(TIMEOUT)s $(ARGS) $(TESTPKGS)

test-xml: fmt lint | $(GO2XUNIT) ; $(info $(M) running $(NAME:%=% )tests...) @ ## Run tests with xUnit output
	$Q mkdir -p test
	$Q 2>&1 $(GO) test -timeout 20s -v $(TESTPKGS) | tee test/tests.output
	$(GO2XUNIT) -fail -input test/tests.output -output test/tests.xml

COVERAGE_MODE = atomic
COVERAGE_PROFILE = $(COVERAGE_DIR)/profile.out
COVERAGE_XML = $(COVERAGE_DIR)/coverage.xml
COVERAGE_HTML = $(COVERAGE_DIR)/index.html
.PHONY: test-coverage test-coverage-tools
test-coverage-tools: | $(GOCOVMERGE) $(GOCOV) $(GOCOVXML)
test-coverage: COVERAGE_DIR := $(CURDIR)/test/coverage.$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
test-coverage: fmt lint test-coverage-tools ; $(info $(M) running coverage tests...) @ ## Run coverage tests
	$Q mkdir -p $(COVERAGE_DIR)/coverage
	$Q for pkg in $(TESTPKGS); do \
		$(GO) test \
			-coverpkg=$$($(GO) list -f '{{ join .Deps "\n" }}' $$pkg | \
					grep '^$(PACKAGE_NAME)/' | \
					tr '\n' ',')$$pkg \
			-covermode=$(COVERAGE_MODE) \
			-coverprofile="$(COVERAGE_DIR)/coverage/`echo $$pkg | tr "/" "-"`.cover" $$pkg ;\
	 done
	$Q $(GOCOVMERGE) $(COVERAGE_DIR)/coverage/*.cover > $(COVERAGE_PROFILE)
	$Q $(GO) tool cover -html=$(COVERAGE_PROFILE) -o $(COVERAGE_HTML)
	$Q $(GOCOV) convert $(COVERAGE_PROFILE) | $(GOCOVXML) > $(COVERAGE_XML)

.PHONY: lint
lint: | $(GOLINT) ; $(info $(M) running golint...) @ ## Run golint
	$Q $(GOLINT) -set_exit_status $(PKGS)

.PHONY: fmt
fmt: ; $(info $(M) running gofmt...) @ ## Run gofmt on all source files
	$Q $(GO) fmt ./...

# Misc

.PHONY: clean
clean: ; $(info $(M) cleaning...)	@ ## Cleanup everything
	@rm -rf $(BIN)
	@rm -rf test/tests.* test/coverage.*

.PHONY: help
help:
	@grep -E '^[ a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

.PHONY: version
version:
	@echo $(VERSION)