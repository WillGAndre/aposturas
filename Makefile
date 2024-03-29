.PHONY: encrypt decrypt

ENC_MTD := aes-256-cbc
PWD_MTD := pbkdf2
CURR := current
ARCH := archive

TIMESTAMP := $(shell date +%Y%m%d%H%M%S)
ARCH_PATH := $(ARCH)/apostura_$(TIMESTAMP).tar.gz.enc

ifndef PASSWORD
	$(error missing password)
endif

encrypt:
	@echo "\n[$(TIMESTAMP)] Encrypting $(CURR) and moving to $(ARCH)..."
	@tar -czf - $(CURR) | openssl enc -$(ENC_MTD) -$(PWD_MTD) -salt -out $(ARCH_PATH) -pass pass:$(PASSWORD)
	@echo "[$(TIMESTAMP)] Encrypted archive at $(ARCH_PATH)"

decrypt:
	@LATEST_ARCHIVE=$$(ls -t $(ARCH)/*.tar.gz.enc | head -1); \
	if [ -z "$$LATEST_ARCHIVE" ]; then \
		echo \n"No archives to decrypt."; \
	else \
		echo "\nDecrypting $$LATEST_ARCHIVE to $(CURR)..."; \
		openssl enc -$(ENC_MTD) -$(PWD_MTD) -d -in $$LATEST_ARCHIVE -out $(ARCH)/latest.tar.gz -pass pass:$(PASSWORD); \
		tar -xzf $(ARCH)/latest.tar.gz -C ./; \
		rm $(ARCH)/latest.tar.gz; \
		echo "Decryption complete."; \
	fi