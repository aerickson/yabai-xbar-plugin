# yabai-xbar-plugin
A xbar (https://github.com/matryer/xbar) plugin for yabai (https://github.com/koekeishiya/yabai).

![main workflow](https://github.com/aerickson/yabai-xbar-plugin/actions/workflows/main.yml/badge.svg)

![current look](https://www.evernote.com/shard/s74/sh/eeaa45d0-ac4c-4206-ad00-d2b8134668d7/c83be9265664a23b/res/cb33bda5-4d10-4359-976a-6a01f5dd10e1)

## features

- indicates if yabai is running or not
- indicates current mission control space
- indicates current desktop mode
  - allows toggling between bsp and float on current desktop
- allows togging of Focus Follows Mouse (FFM)

### installation

- install xbar
  - https://github.com/matryer/xbar
- copy plugin to xbar plugin folder
  - `cp yabai_skhd.1s.sh $HOME/Library/Application\ Support/xbar/plugins/`
  - or run `make deploy`

### TODO

- integrate directions for making the plugin only run on space change, etc
  - https://github.com/SxC97/Yabai-Spaces/wiki/Yabai-and-SHKD-Integration
- makefile symlinks vs copies

### links

- https://github.com/SxC97/Yabai-Spaces
  - another bitbar/xbar plugin for yabai
