# Makefile for Flutter Bricks Project

.PHONY: help init add-all make-mvvm test-all clean showcase-build

help:
	@echo "Available commands:"
	@echo "  init           - Initialize mason and add all bricks locally"
	@echo "  add-all        - Add all bricks from the bricks/ directory"
	@echo "  make-mvvm      - Generate a new MVVM project (interactive)"
	@echo "  test-all       - Run tests for all bricks (simulated)"
	@echo "  clean          - Remove generated artifacts and mason cache"
	@echo "  showcase-build - Run build_runner in the showcase app"

init:
	mason init
	$(MAKE) add-all

add-all:
	@for dir in bricks/*/ ; do \
		brick_name=$$(basename $$dir); \
		echo "Adding brick: $$brick_name"; \
		mason add $$brick_name --path ./bricks/$$brick_name --force; \
	done

make-mvvm:
	mason make flutter_mvvm

test-all:
	@echo "Validating brick templates..."
	@for dir in bricks/*/ ; do \
		brick_name=$$(basename $$dir); \
		if [ -f "$$dir/brick.yaml" ]; then \
			echo "✅ $$brick_name: brick.yaml found"; \
		else \
			echo "❌ $$brick_name: brick.yaml MISSING"; \
			exit 1; \
		fi \
	done

showcase-build:
	cd examples/showcase_app && flutter pub get && dart run build_runner build --delete-conflicting-outputs

clean:
	rm -rf .mason
	rm mason-lock.json
