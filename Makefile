.PHONY : usage deploy

usage:
	$(info USAGE: run 'make deploy' to copy the plugin to your swiftbar plugin dir)

deploy:
	cp yabai_skhd.1s.sh ${HOME}/.swiftbar/
	open -g 'swiftbar://app.swiftbarapp.com/refreshPlugin?name=yabai.*?.sh'
