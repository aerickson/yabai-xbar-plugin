#!/bin/bash

# for debugging only
# set -x

# <xbar.title>yabai helper</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.author>Andrew Erickson</xbar.author>
# <xbar.author.github>aerickson</xbar.author.github>
# <xbar.desc>Plugin that displays desktop id and desktop mode of yabai.</xbar.desc>
# <xbar.dependencies>yabai,skhd</xbar.dependencies>

# Info about yabai, see: https://github.com/koekeishiya/yabai
# For skhd, see: https://github.com/koekeishiya/skhd

#
# feature flags
#
FEATURE_SHOW_FFM='yes'
# only used when ffm plugin detection is working
# can be autofocus or autoraise
FEATURE_SHOW_FFM_MODE='autofocus'
FEATURE_SHOW_EQUALIZE='no'
# TODO: make these work
# FEATURE_CONTROL_SKHD_SERVICE  # whether to start/stop skhd when yabai is started/stopped
# FEATURE_SHOW_DESKTOP_ID='yes'

#############################################################
#        !!! NO USER SETTINGS BELOW !!!
#############################################################

function refreshBB {
  open -g 'xbar://app.xbarapp.com/refreshPlugin?name=yabai.*?.sh'
  # backup plan: update all
  # open -g 'xbar://app.xbarapp.com/refreshAllPlugins'
}

export PATH=/usr/local/bin:/opt/homebrew/bin:$PATH

#
# verify feature flag settings
#
if [[ "$FEATURE_SHOW_FFM_MODE" = "autofocus" ]]; then
  # ok, pass
  :
elif [[ "$FEATURE_SHOW_FFM_MODE" = "autoraise" ]]; then
  # also ok, pass
  :
else
  echo "invalid setting for FEATURE_SHOW_FFM_MODE"
  exit 1
fi

# how to write to stderr for debugging
# echo "test 123" >&2

# VER=$(yabai --version)
SPACE_INFO_CMD=$(yabai -m query --spaces --space 2>&1)
rc=$?
if [[ $rc -eq 0 ]]; then
  CURRENT_MODE=$(echo $SPACE_INFO_CMD | jq .type 2>&1)
  case $CURRENT_MODE in
  '"bsp"')
    CHUNK_STATE='running'
    MODE='bsp'
    MODE_TOGGLE='float'
    MODE_EMOJI='⊞'
    ;;
  '"float"')
    MODE='float'
    CHUNK_STATE='running'
    MODE_TOGGLE='bsp'
    MODE_EMOJI='⧉'
    ;;
  *)
    # echo "$CURRENT_MODE"
    CHUNK_STATE='stopped'
    MODE_EMOJI="⧄"
    ;;
  esac
else
  # echo "$CURRENT_MODE"
  CHUNK_STATE='stopped'
  MODE_EMOJI="⧄"
fi

FFM_STATE=$(yabai -m config focus_follows_mouse 2>&1)

#
# command handlers
#
SLEEP_TIME=1
if [[ "$1" = "stop" ]]; then
  # launchctl stop com.koekeishiya.yabai
  # launchctl stop com.koekeishiya.skhd
  skhd --stop-service
  yabai --stop-service
  refreshBB
elif [[ "$1" = "start" ]]; then
  # launchctl start com.koekeishiya.yabai
  yabai --start-service
  skhd --start-service
  sleep $SLEEP_TIME
  refreshBB
elif [[ "$1" = "restart" ]]; then
  # launchctl stop com.koekeishiya.yabai
  # launchctl start com.koekeishiya.yabai
  yabai --restart-service
  skhd --restart-service
  sleep $SLEEP_TIME
  refreshBB
elif [[ "$1" = "dfocus" ]]; then
  yabai -m config focus_follows_mouse off
  sleep 0.2
  refreshBB
elif [[ "$1" = "efocus-autoraise" ]]; then
  yabai -m config focus_follows_mouse autoraise
  sleep 0.2
  refreshBB
elif [[ "$1" = "efocus-autofocus" ]]; then
  yabai -m config focus_follows_mouse autofocus
  sleep 0.2
  refreshBB
elif [[ "$1" = "toggle" ]]; then
  yabai -m space --layout $MODE_TOGGLE
  refreshBB
elif [[ "$1" = "equalize" ]]; then
  # TODO: doesn't work. figure out new command.
  yabai tiling::desktop --equalize
  refreshBB
else
  #
  # display block
  #
  if [[ "$CHUNK_STATE" = "running" ]]; then
    # TODO: hide display of desktop id behind flag?
    echo "y ${MODE_EMOJI} $(yabai -m query --spaces --space | jq .index) | length=10"
  else
    echo "y ${MODE_EMOJI}"
  fi
  echo "---"
  if [[ "$CHUNK_STATE" = "running" ]]; then
    # TODO: selector for all 3 modes?
    echo "Desktop Mode: ${MODE}"
    echo "Toggle Layout | bash='$0' param1=toggle terminal=false"
    if [[ "$FEATURE_SHOW_EQUALIZE" == 'yes' ]]; then
      echo "Equalize Windows | bash='$0' param1=equalize terminal=false"
    fi

    # focus follow mouse code
    if [[ "$FEATURE_SHOW_FFM" == 'yes' ]]; then
      echo "---"
      if [[ "$YABAI_PLUGIN_DETECTION_WORKING" == "yes" ]]; then
        if [[ "$FFM_ENABLED" = "yes" ]]; then
          echo "Disable FFM | bash='$0' param1=dfocus terminal=false"
        else
          echo "Enable FFM | bash='$0' param1=efocus terminal=false"
        fi
      else
        echo "FFM: $FFM_STATE"
        if ([ "$FFM_STATE" = 'disabled' ] || [ "$FFM_STATE" = 'autoraise' ]); then
          echo "FFM Autofocus | bash='$0' param1=efocus-autofocus terminal=false"
        fi
        if ([ "$FFM_STATE" = 'disabled' ] || [ "$FFM_STATE" = 'autofocus' ]); then
          echo "FFM Autoraise | bash='$0' param1=efocus-autoraise terminal=false"
        fi
        if ([ "$FFM_STATE" = 'autofocus' ] || [ "$FFM_STATE" = 'autoraise' ]); then
          echo "FFM Off | bash='$0' param1=dfocus terminal=false"
        fi
      fi
    fi
    echo "---"
  fi

  echo "yabai: $CHUNK_STATE"
  if [[ "$CHUNK_STATE" = "running" ]]; then
    echo "Restart yabai | bash='$0' param1=restart terminal=false"
    echo "Stop yabai | bash='$0' param1=stop terminal=false"
  else
    echo "Start yabai | bash='$0' param1=start terminal=false"
  fi
  # TODO: add back in control of skhd? behind a flag or option?

fi
