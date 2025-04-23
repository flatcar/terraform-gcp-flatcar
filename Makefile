# Get the current date in YYYYMMDD format
DATE := $(shell date +%Y%m%d)

# Prefix to use for cleaning / creating
ZIP_NAME_PREFIX := flatcar-deployment-package

# Name of the output zip file
ZIP_NAME := "${ZIP_NAME_PREFIX}-${DATE}.zip"

# Default target to create the zip
all: package

# Rule to create the zip file
package: clean
	zip -r $(ZIP_NAME) *.tf *.yaml LICENSE README.md

# Clean target to remove the zip file
clean:
	rm -f $(ZIP_NAME_PREFIX)-*.zip
