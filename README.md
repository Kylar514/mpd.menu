# mpd.menu

An [Omarchy](https://omarchy.org/) shell plugin: a Quickshell menu that drives
[MPD](https://www.musicpd.org/) through [`mpc`](https://www.musicpd.org/clients/mpc/)
— built for the speed of `mpc one-liners` everywhere a click lands.

Forked from Omarchy's first-party menu engine (the same fork lineage as
`zeal.menu`) — the row list, dynamic providers, search, and key codes are the
engine you know; the identity, contents and data layer are all MPD.

<!-- screenshot placeholder — drop docs/screenshot.png and uncomment below
![screenshot](docs/screenshot.png)
-->

## Install

```sh
omarchy plugin add https://github.com/Kylar514/mpd.menu.git --enable --yes
```

Open it with the default hotkey `SUPER + SHIFT + M` (see Dotfiles below), or by
IPC:

```sh
omarchy-shell shell toggle mpd.menu
```

Updates after install are handled by `omarchy plugin update mpd.menu` — not
`install.sh` (that script exists for local development only).

## Requirements

| Tool | Why |
| --- | --- |
| `mpd` | the daemon itself |
| `mpc` | every menu action is a one-liner through it |
| `yt-dlp` | only needed for the YouTube bridge rows |

## Menu rows

| Row | What it does |
| --- | --- |
| **Now playing** *(dynamic, click-back row)* | `mpc current` via a provider; clicking toggles playback |
| **Start / Stop mpd** | `systemctl --user start/stop mpd.service` — only visible when the daemon is down |
| Play / Pause, Next, Previous, Stop | `mpc toggle / next / prev / stop` |
| Random / Repeat / Consume | label flips "on"/"off" from one batched `mpc status` read |
| Shuffle queue | `mpc shuffle` |
| Playlists › … | `mpc lsplaylists`; picking one runs `mpc clear; mpc load <pl>; mpc play` |
| Playlists → Browse current queue | numbered list → `omarchy-menu-select` → `mpc play <pos>` (instant jump) |
| Library → Play YouTube / URL | YouTube URLs expand into direct audio streams (below); anything else is `mpc load` |
| Library → Download YouTube playlist | `yt-dlp -x` into `~/Music/songs/<title>/` + `mpc update` — permanent offline copy |
| Library → Save queue as playlist | `mpc save "<name>"` |
| Library → Update music database | `mpc update` |

Daemon-down? The menu degrades to Start + Library rows only (guards via
`mpc status` exit code, batched — cheap before every open).

## Keyboard

| Key | Action |
| --- | --- |
| `↑ / ↓` / `Ctrl+J / Ctrl+K` | move cursor |
| `Enter / →` / `Ctrl+L` | open submenu / fire row |
| `←` / `Backspace` / `Ctrl+H` | go back — cursor❶ restores the row you left the previous menu on |
| `Esc` | close (or clear search first) |
| plain letters | type to search (filter) |
| **Ctrl+V / Ctrl+Shift+V** | paste — first clipboard line only |

`❶` position memory lives in the menu's `originIndex` map — the row you drilled in
from is what gets restored, per the original zeal.menu behavior.

## YouTube bridge (`bin/mpd-youtube-load`)

MPD ships **no YouTube plugin**, so the bridge does the yt-dlp work itself:

1. `yt-dlp --flat-playlist -J` finds the entries in a youtube playlist URL
2. each entry gets a `yt-dlp -f bestaudio --get-url` pass → a direct
   `googlevideo.com` audio stream that mpd plays natively via its `http`/`ffmpeg`
   inputs
3. Streams are written as `YT - <title>.m3u` into `~/Music/playlists` with real
   track titles via `#EXTINF`, then `mpc clear; mpc load <name>; mpc play`

Caveats, honestly stated:

- the stream URLs **expire (~6 h)** — replaying later means re-running the row (or
  rotating a download instead — see Download row: it leaves permanent `.opus`
  files under `~/Music/songs/<playlist>/`)
- Google anti-bot breakage until yt-dlp updates — same fragility any YT-reading
  player inherits
- **one expansion at a time** — the script `flock`s an `$XDG_RUNTIME_DIR`
  lockfile so double-launches can't interleave writes/races (exit 0 + a
  notification, no file corruption)
- private/unavailable tracks are skipped and logged to
  `~/.cache/omarchy/mpd.menu/ytdlp-expand.err`

## Config overrides

Without touching this repo you can override any row (label/icon/action) in
`~/.config/omarchy/extensions/mpd-menu.jsonc` — same keys, same ids as the
bundled file; overrides that file wins on merge.

## License

MIT — see [LICENSE](LICENSE).
