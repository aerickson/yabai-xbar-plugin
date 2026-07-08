.PHONY : usage deploy

usage:
	$(info USAGE: run 'make deploy' to install the plugin to your swiftbar plugin dir)

deploy:
	./install.sh
