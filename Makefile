.PHONY : usage deploy

usage:
	$(info USAGE: run 'make deploy' to copy the plugin to your xbar plugin dir)

deploy:
	cp yabai_skhd.1s.sh ${HOME}/Library/Application\ Support/xbar/plugins/
	open -g 'xbar://app.xbarapp.com/refreshPlugin?name=yabai.*?.sh'
