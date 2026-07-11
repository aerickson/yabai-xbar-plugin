# Plugin Review

## Overall assessment

The plugin is a solid, readable single-file SwiftBar plugin. Recent restart work improved observability and compatibility with SwiftBar. It is usable today, but the service lifecycle handling is not fully robust yet.

## Findings

### High priority

#### Combined service actions do not wait for `skhd`

`stop_services` waits for yabai to stop, but not for `skhd`. Likewise, `start_services` waits for yabai to start, but not for `skhd`.

As a result, the plugin can report that a combined start, stop, or restart succeeded while `skhd` is still running, has not stopped yet, or failed to launch.

Relevant code: [yabai_skhd.1s.sh:83](/Users/aje/git/yabai-xbar-plugin/yabai_skhd.1s.sh:83)

Recommended fix: call the existing `wait_for_skhd up/down` checks from the combined service functions.

### Medium priority

#### Focus and layout action failures are ignored

The focus-follow-mouse and layout commands do not log failures or update the action status:

- `yabai -m config focus_follows_mouse ...`
- `yabai -m space --layout ...`

Relevant code: [yabai_skhd.1s.sh:255](/Users/aje/git/yabai-xbar-plugin/yabai_skhd.1s.sh:255)

Recommended fix: route these commands through `run_cmd`, check their return codes, and surface failures in the menu status.

#### `skhd` restart validation is weak

`restart_skhd` considers the operation successful if any process named `skhd` exists after the command. This does not prove that the service actually restarted or that the new process is healthy.

Relevant code: [yabai_skhd.1s.sh:143](/Users/aje/git/yabai-xbar-plugin/yabai_skhd.1s.sh:143)

Recommended fix: validate the launch service state or perform a down-then-up transition rather than checking only for process presence.

### Low priority

#### Unused feature setting

`FEATURE_SHOW_FFM_MODE` is validated but never used to control behavior.

Relevant code: [yabai_skhd.1s.sh:154](/Users/aje/git/yabai-xbar-plugin/yabai_skhd.1s.sh:154)

Recommended fix: either use the setting or remove it.

#### Dependency checks are implicit

The plugin assumes that `jq`, `pgrep`, `open`, `yabai`, and `skhd` are available. Missing dependencies will produce incomplete or confusing output.

Recommended fix: document the full dependency list and provide a clear startup error when required commands are unavailable.

#### Log file has no rotation

`/tmp/yabai_xbar_plugin.log` grows indefinitely while the plugin is used.

Recommended fix: cap the log size or retain only the most recent entries.

#### Predictable temporary filenames

The plugin writes to fixed paths in `/tmp`:

- `/tmp/yabai_xbar_plugin.log`
- `/tmp/yabai_xbar_plugin.status`

This is acceptable for a personal macOS plugin, but predictable temporary files are less robust than per-user paths or securely created files.

## Strengths

- Clear separation between display logic and service operations.
- Explicit PATH setup supports common Homebrew installations.
- Restart operations log commands, return codes, and user-visible status.
- SwiftBar refresh is now the default, with optional legacy xbar refresh support.
- The installer refuses to overwrite an existing regular file.
- The plugin has independent `skhd` status and controls.

## Validation performed

- `bash -n` passed for the plugin, installer, and experimental scripts.
- `shfmt -d -i 2` passed.
- Pre-commit checks passed.
- No automated behavioral test suite is present.
- The working tree contained an existing untracked file: `RESTART_FIX_TRACKING.md`.

## Recommended next steps

1. Add `wait_for_skhd` checks to the combined start/stop/restart paths.
2. Add consistent error handling for focus and layout actions.
3. Add a small mocked test harness for service success and failure cases.
4. Decide whether `RESTART_FIX_TRACKING.md` should be committed as project documentation or removed.
