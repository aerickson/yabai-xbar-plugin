# yabai-xbar-plugin
A yabai plugin for yabai (https://github.com/koekeishiya/yabai) for Bitbar/xbar/SwiftBar.

Bitbar and xbar are not maintained. Use with SwiftBar. `brew install swiftbar`

![main workflow](https://github.com/aerickson/yabai-xbar-plugin/actions/workflows/main.yml/badge.svg)

![current look](https://www.evernote.com/shard/s74/sh/eeaa45d0-ac4c-4206-ad00-d2b8134668d7/c83be9265664a23b/res/cb33bda5-4d10-4359-976a-6a01f5dd10e1)

## features

- indicates if yabai is running or not
- indicates current mission control space
- indicates current desktop mode
  - allows toggling between bsp and float on current desktop
- indicates Focus Follows Mouse (FFM) mode
  - allows togging of FFM modes
- allows starting/stopping/restarting yabai

### installation

- install SwiftBar
  - `brew install swiftbar`
- install the plugin into `~/.swiftbar`
  - `./install.sh`
  - or run `make deploy`
- set SwiftBar to use `~/.swiftbar`
  - open SwiftBar from the menu bar
  - open Preferences/Settings and choose the plugin folder/location
  - select `~/.swiftbar`
  - if the file picker does not show hidden folders, press `Cmd+Shift+G`, enter `~/.swiftbar`, and select it

### TODO

- integrate directions for making the plugin only run on space change, etc
  - https://github.com/SxC97/Yabai-Spaces/wiki/Yabai-and-SHKD-Integration

### links

- https://github.com/SxC97/Yabai-Spaces
  - another bitbar/xbar plugin for yabai
