# Makefile for OCSF-MOQ Mapping RFC Document
# Converts kramdown-rfc to various output formats using xml2rfc

# Document name (without extension)
DOCNAME = draft-privacy-pass-moq-auth

# Source files
KRAMDOWN_SRC = $(DOCNAME).md
XML_SRC = $(DOCNAME).xml

# Output files
TXT_OUT = $(DOCNAME).txt
HTML_OUT = $(DOCNAME).html
PDF_OUT = $(DOCNAME).pdf

# Tools
KRAMDOWN_RFC = kramdown-rfc
XML2RFC = xml2rfc

# Default target
.PHONY: all
all: txt html

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all       - Build text and HTML versions (default)"
	@echo "  txt       - Build text version"
	@echo "  html      - Build HTML version"
	@echo "  pdf       - Build PDF version"
	@echo "  xml       - Convert kramdown to XML"
	@echo "  clean     - Remove generated files"
	@echo "  install   - Install required tools"
	@echo "  check     - Check if required tools are installed"
	@echo "  help      - Show this help message"

# Check if required tools are installed
.PHONY: check
check:
	@echo "Checking for required tools..."
	@which $(KRAMDOWN_RFC) > /dev/null 2>&1 || { echo "Error: kramdown-rfc not found. Run 'make install' or install with 'gem install kramdown-rfc'"; exit 1; }
	@which $(XML2RFC) > /dev/null 2>&1 || { echo "Error: xml2rfc not found. Run 'make install' or install with 'pip install xml2rfc'"; exit 1; }
	@echo "All required tools are installed."

# Install required tools
.PHONY: install
install:
	@echo "Installing required tools..."
	@echo "Installing kramdown-rfc (requires Ruby and gem)..."
	gem install kramdown-rfc
	@echo "Installing xml2rfc (requires Python and pip)..."
	pip install xml2rfc
	@echo "Installation complete."

# Convert kramdown to XML
$(XML_SRC): $(KRAMDOWN_SRC)
	@echo "Converting $(KRAMDOWN_SRC) to XML..."
	$(KRAMDOWN_RFC) $(KRAMDOWN_SRC) > $(XML_SRC)

# Build XML target
.PHONY: xml
xml: $(XML_SRC)

# Build text version
$(TXT_OUT): $(XML_SRC)
	@echo "Converting $(XML_SRC) to text..."
	$(XML2RFC) --text $(XML_SRC) -o $(TXT_OUT)

.PHONY: txt
txt: check $(TXT_OUT)

# Build HTML version
$(HTML_OUT): $(XML_SRC)
	@echo "Converting $(XML_SRC) to HTML..."
	$(XML2RFC) --html $(XML_SRC) -o $(HTML_OUT)

.PHONY: html
html: check $(HTML_OUT)

# Build PDF version (requires additional dependencies)
$(PDF_OUT): $(XML_SRC)
	@echo "Converting $(XML_SRC) to PDF..."
	$(XML2RFC) --pdf $(XML_SRC) -o $(PDF_OUT)

.PHONY: pdf
pdf: check $(PDF_OUT)

# Clean generated files
.PHONY: clean
clean:
	@echo "Cleaning generated files..."
	rm -f $(XML_SRC) $(TXT_OUT) $(HTML_OUT) $(PDF_OUT)
	@echo "Clean complete."

# Watch for changes and rebuild (requires entr or inotify-tools)
.PHONY: watch
watch:
	@echo "Watching $(KRAMDOWN_SRC) for changes..."
	@which entr > /dev/null 2>&1 && { \
		echo "Using entr for file watching..."; \
		echo $(KRAMDOWN_SRC) | entr -c make all; \
	} || { \
		echo "Error: 'entr' not found. Install with your package manager (e.g., 'brew install entr' on macOS)"; \
		exit 1; \
	}

# Validate XML output
.PHONY: validate
validate: $(XML_SRC)
	@echo "Validating XML..."
	$(XML2RFC) --verbose $(XML_SRC) > /dev/null

# Show document statistics
.PHONY: stats
stats: $(TXT_OUT)
	@echo "Document Statistics:"
	@echo "==================="
	@echo "Lines: $$(wc -l < $(TXT_OUT))"
	@echo "Words: $$(wc -w < $(TXT_OUT))"
	@echo "Characters: $$(wc -c < $(TXT_OUT))"
	@echo "Pages (approx): $$(echo "$$(wc -l < $(TXT_OUT)) / 58" | bc)"

# Preview HTML in browser (macOS/Linux)
.PHONY: preview
preview: $(HTML_OUT)
	@echo "Opening $(HTML_OUT) in browser..."
	@if command -v open > /dev/null 2>&1; then \
		open $(HTML_OUT); \
	elif command -v xdg-open > /dev/null 2>&1; then \
		xdg-open $(HTML_OUT); \
	else \
		echo "Could not detect browser command. Please open $(HTML_OUT) manually."; \
	fi

# Upload to datatracker (placeholder - requires authentication setup)
.PHONY: upload
upload: $(TXT_OUT)
	@echo "Note: Manual upload to IETF datatracker required."
	@echo "Upload $(TXT_OUT) to: https://datatracker.ietf.org/submit/"

# Development target - builds all formats and shows stats
.PHONY: dev
dev: all stats
	@echo "Development build complete."

# Force rebuild
.PHONY: force
force: clean all

# Dependencies
$(TXT_OUT): $(KRAMDOWN_SRC)
$(HTML_OUT): $(KRAMDOWN_SRC)
$(PDF_OUT): $(KRAMDOWN_SRC)

# Mark intermediate XML file as precious to avoid deletion
.PRECIOUS: $(XML_SRC)
