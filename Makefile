SRC_DIR := src
OUT_DIR := out

SOURCES := $(wildcard $(SRC_DIR)/*.txt)

OUTPUTS := $(patsubst $(SRC_DIR)/%.txt,$(OUT_DIR)/%.txt,$(SOURCES))

.PHONY: all check build test clean ci help report

all: test ## Build and test the project

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

$(OUT_DIR)/%.txt: $(SRC_DIR)/%.txt | $(OUT_DIR)
	@echo "Building $< -> $@"
	tr '[:lower:]' '[:upper:]' < "$<" > "$@"

check: ## Check that source files exist
	@test -d "$(SRC_DIR)" || { echo "ERROR: $(SRC_DIR) directory is missing"; exit 1; }
	@test "$(words $(SOURCES))" -gt 0 || { echo "ERROR: no .txt files found in $(SRC_DIR)"; exit 1; }
	@echo "CHECK OK: found $(words $(SOURCES)) .txt files in $(SRC_DIR)"

build: $(OUTPUTS) ## Build all outputs

test: build ## Verify outputs contain no lowercase letters
	@for f in $(OUTPUTS); do \
		if grep -q '[[:lower:]]' "$$f"; then \
			echo "TEST FAILED: lowercase letter found in $$f"; \
			exit 1; \
		fi; \
	done
	@echo "TEST PASSED"

clean: ## Remove generated outputs
	rm -rf $(OUT_DIR)

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS=":.*## "}; {printf "  %-10s %s\n", $$1, $$2}'

report: $(OUTPUTS) ## Generate build report
	@echo "Build Report" > $(OUT_DIR)/report.txt
	@echo "Generated: $$(date)" >> $(OUT_DIR)/report.txt
	@echo "" >> $(OUT_DIR)/report.txt
	@for f in $(OUTPUTS); do \
		echo "$$f: $$(wc -l < "$$f") lines" >> $(OUT_DIR)/report.txt; \
	done
	@echo "Report written to $(OUT_DIR)/report.txt"

ci: clean check test ## Clean, check, build and test
