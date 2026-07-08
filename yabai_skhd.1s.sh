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
# FEATURE_SHOW_DESKTOP_ID='yes'

#############################################################
#        !!! NO USER SETTINGS BELOW !!!
#############################################################

function refreshBB {
  open -g 'swiftbar://app.swiftbarapp.com/refreshPlugin?name=yabai.*?.sh' >/dev/null 2>&1
  if [[ "${YABAI_XBAR_REFRESH_LEGACY:-no}" = "yes" ]]; then
    open -g 'xbar://app.xbarapp.com/refreshPlugin?name=yabai.*?.sh' >/dev/null 2>&1
  fi
}

export PATH=/usr/local/bin:/opt/homebrew/bin:$PATH
ACTION_LOG="/tmp/yabai_xbar_plugin.log"
ACTION_STATUS="/tmp/yabai_xbar_plugin.status"

# Resolve symlink so the path used in bash= menu params has no spaces
SELF=$(readlink "$0" || echo "$0")

function log_msg {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >>"$ACTION_LOG"
}

function set_status {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >"$ACTION_STATUS"
}

function run_cmd {
  log_msg "+ $*"
  "$@" >>"$ACTION_LOG" 2>&1
  local rc=$?
  log_msg "rc=$rc $*"
  return $rc
}

function wait_for_yabai {
  local target="$1"
  local attempts=20
  local delay=0.25
  local i=0

  while [[ $i -lt $attempts ]]; do
    yabai -m query --spaces --space >/dev/null 2>&1
    local rc=$?
    if [[ "$target" = "up" && $rc -eq 0 ]]; then
      return 0
    fi
    if [[ "$target" = "down" && $rc -ne 0 ]]; then
      return 0
    fi
    sleep "$delay"
    i=$((i + 1))
  done

  return 1
}

function stop_services {
  local rc=0
  run_cmd skhd --stop-service || rc=1
  run_cmd yabai --stop-service || rc=1
  wait_for_yabai down || rc=1
  return $rc
}

function start_services {
  local rc=0
  run_cmd yabai --start-service || rc=1
  wait_for_yabai up || rc=1
  run_cmd skhd --start-service || rc=1
  return $rc
}

function restart_services {
  local rc=0
  log_msg "restart requested"
  stop_services || rc=1
  start_services || rc=1
  return $rc
}

function wait_for_skhd {
  local target="$1"
  local attempts=20
  local delay=0.25
  local i=0

  while [[ $i -lt $attempts ]]; do
    pgrep -x skhd >/dev/null 2>&1
    local rc=$?
    if [[ "$target" = "up" && $rc -eq 0 ]]; then
      return 0
    fi
    if [[ "$target" = "down" && $rc -ne 0 ]]; then
      return 0
    fi
    sleep "$delay"
    i=$((i + 1))
  done

  return 1
}

function stop_skhd {
  local rc=0
  run_cmd skhd --stop-service || rc=1
  wait_for_skhd down || rc=1
  return $rc
}

function start_skhd {
  local rc=0
  run_cmd skhd --start-service || rc=1
  wait_for_skhd up || rc=1
  return $rc
}

function restart_skhd {
  local rc=0
  log_msg "skhd restart requested"
  run_cmd skhd --restart-service || rc=1
  wait_for_skhd up || rc=1
  return $rc
}

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
  FFM_STATE=$(yabai -m config focus_follows_mouse 2>&1)
else
  # echo "$CURRENT_MODE"
  CHUNK_STATE='stopped'
  MODE_EMOJI="⧄"
fi

if pgrep -x skhd &>/dev/null; then
  SKHD_STATE='running'
else
  SKHD_STATE='stopped'
fi

#
# command handlers
#
SLEEP_TIME=1
if [[ "$1" = "stop" ]]; then
  if stop_services; then
    set_status "Stopped yabai/skhd"
  else
    set_status "Stop may have failed; see $ACTION_LOG"
  fi
  refreshBB
elif [[ "$1" = "start" ]]; then
  if start_services; then
    set_status "Started yabai/skhd"
  else
    set_status "Start may have failed; see $ACTION_LOG"
  fi
  sleep $SLEEP_TIME
  refreshBB
elif [[ "$1" = "restart" ]]; then
  if restart_services; then
    set_status "Restarted yabai/skhd"
  else
    set_status "Restart may have failed; see $ACTION_LOG"
  fi
  sleep $SLEEP_TIME
  refreshBB
elif [[ "$1" = "skhd-stop" ]]; then
  if stop_skhd; then
    set_status "Stopped skhd"
  else
    set_status "Stop skhd may have failed; see $ACTION_LOG"
  fi
  refreshBB
elif [[ "$1" = "skhd-start" ]]; then
  if start_skhd; then
    set_status "Started skhd"
  else
    set_status "Start skhd may have failed; see $ACTION_LOG"
  fi
  sleep $SLEEP_TIME
  refreshBB
elif [[ "$1" = "skhd-restart" ]]; then
  if restart_skhd; then
    set_status "Restarted skhd"
  else
    set_status "Restart skhd may have failed; see $ACTION_LOG"
  fi
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
    echo "Toggle Layout | bash='$SELF' param1=toggle terminal=false"
    if [[ "$FEATURE_SHOW_EQUALIZE" == 'yes' ]]; then
      echo "Equalize Windows | bash='$SELF' param1=equalize terminal=false"
    fi

    # focus follow mouse code
    if [[ "$FEATURE_SHOW_FFM" == 'yes' ]]; then
      echo "---"
      if [[ "$YABAI_PLUGIN_DETECTION_WORKING" == "yes" ]]; then
        if [[ "$FFM_ENABLED" = "yes" ]]; then
          echo "Disable FFM | bash='$SELF' param1=dfocus terminal=false"
        else
          echo "Enable FFM | bash='$SELF' param1=efocus terminal=false"
        fi
      else
        echo "FFM: $FFM_STATE"
        if ([ "$FFM_STATE" = 'disabled' ] || [ "$FFM_STATE" = 'autoraise' ]); then
          echo "FFM Autofocus | bash='$SELF' param1=efocus-autofocus terminal=false"
        fi
        if ([ "$FFM_STATE" = 'disabled' ] || [ "$FFM_STATE" = 'autofocus' ]); then
          echo "FFM Autoraise | bash='$SELF' param1=efocus-autoraise terminal=false"
        fi
        if ([ "$FFM_STATE" = 'autofocus' ] || [ "$FFM_STATE" = 'autoraise' ]); then
          echo "FFM Off | bash='$SELF' param1=dfocus terminal=false"
        fi
      fi
    fi
    echo "---"
  fi

  echo "yabai: $CHUNK_STATE"
  if [[ -f "$ACTION_STATUS" ]]; then
    echo "Last action: $(tail -n 1 "$ACTION_STATUS")"
    echo "Action log: $ACTION_LOG"
  fi
  if [[ "$CHUNK_STATE" = "running" ]]; then
    echo "Restart yabai/skhd | bash='$SELF' param1=restart terminal=false"
    echo "Stop yabai/skhd | bash='$SELF' param1=stop terminal=false"
  else
    echo "Start yabai/skhd | bash='$SELF' param1=start terminal=false"
  fi
  echo "---"
  echo "skhd: $SKHD_STATE"
  if [[ "$SKHD_STATE" = "running" ]]; then
    echo "Restart skhd | bash='$SELF' param1=skhd-restart terminal=false"
    echo "Stop skhd | bash='$SELF' param1=skhd-stop terminal=false"
  else
    echo "Start skhd | bash='$SELF' param1=skhd-start terminal=false"
  fi

fi
