# Kodi Remote

## What is it?

kodiRemote is a Chrome extension to browse Kodi and acts as a remote control.

## Build

`gulp`

## Install

- download and unpack the zip file (`Download ZIP` on right side)
- go to `chrome://extensions`
- check `Developer mode` (top right)
- click `Load unpacked extension...` (top left)
- point it to the extension (the folder with the manifest.json file)
- click `Select`

## Kodi Settings

The extension uses websockets or HTTP connections. See [Enabling JSON-RPC](http://kodi.wiki/view/JSON-RPC_API#Enabling_JSON-RPC) how to enable it.

# Functions

- browse, search, scan and clean libraries
- play, stop, pause, fast forward, rewind, seek within a video, download
- toggle subtitles and audio streams
- update server settings
- remote control with up, down, left, right, back, select, info, home, scan and clean buttons

# TODO

- browse Music library
- browse files
- proper playlists