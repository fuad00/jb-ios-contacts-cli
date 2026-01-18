# --- Auto-detect Shell for iOS Jailbreak ---
# Пытаемся найти sh в разных местах.
# wildcard вернет путь, если файл существует.
DETECTED_SHELL := $(firstword $(wildcard /var/jb/bin/sh /var/jb/usr/bin/sh /bin/sh /usr/bin/sh /var/jb/bin/bash))

# Если нашли - используем его. Если нет - оставляем дефолт (make сам решит, но может упасть)
ifneq ($(DETECTED_SHELL),)
  SHELL := $(DETECTED_SHELL)
endif
# -------------------------------------------

TARGET = contacts
SOURCE = contacts.m
ENTITLEMENTS = ent.xml
CC = clang
CFLAGS = -fmodules -Wall
SIGN = ldid
SIGNFLAGS = -S$(ENTITLEMENTS)

# Цель по умолчанию
all: $(TARGET)

$(TARGET): $(SOURCE) $(ENTITLEMENTS)
	@echo "Using Shell: $(SHELL)"
	@echo "Compiling $(SOURCE)..."
	$(CC) $(CFLAGS) -o $(TARGET) $(SOURCE)
	@echo "Signing $(TARGET)..."
	-chmod 644 $(TARGET)
	$(SIGN) $(SIGNFLAGS) $(TARGET)
	-chmod 755 $(TARGET)
	@echo "Build successful! Run: ./$(TARGET)"

clean:
	@echo "Cleaning up..."
	rm -f $(TARGET)

rebuild: clean all
