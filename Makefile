# Makefile для iOS утилиты contacts

TARGET = contacts
SOURCE = contacts.m
ENTITLEMENTS = ent.xml
CC = clang
CFLAGS = -fmodules -Wall -Werror
SIGN = ldid
SIGNFLAGS = -S$(ENTITLEMENTS)

all: $(TARGET)

$(TARGET): $(SOURCE) $(ENTITLEMENTS)
	@echo "Compiling $(SOURCE)..."
	$(CC) $(CFLAGS) -o $(TARGET) $(SOURCE)
	@echo "Signing $(TARGET)..."
	@chmod 644 $(TARGET)
	$(SIGN) $(SIGNFLAGS) $(TARGET)
	@chmod 755 $(TARGET)
	@echo "Build successful! Run ./$(TARGET)"

clean:
	@echo "Cleaning up..."
	rm -f $(TARGET)

rebuild: clean all
