# bat.yazi

Use [bat](https://github.com/sharkdp/bat) as a file previewer in Yazi, with line numbers, syntax highlighting, and word wrapping.

## Require

Make sure you have [bat](https://github.com/sharkdp/bat) installed, and it can be found in `PATH`.

This plugin targets the Yazi plugin API as of v26.9.1. If you are on an older Yazi and see errors like `attempt to call a nil value (method 'args')`, you are running a Yazi version this plugin does not support.

## Install

```bash
# With the Yazi package manager
ya pkg add KKV9/bat
```

```bash
# Or with git
git clone https://github.com/KKV9/bat.yazi.git ~/.config/yazi/plugins/bat.yazi     # Unix
git clone https://github.com/KKV9/bat.yazi.git %AppData%\yazi\config\plugins\bat.yazi # Windows
```

## Usage

Add this to your `yazi.toml`:

```toml
[plugin]
prepend_previewers = [
	{ mime = "text/*", run = "bat" },
	{ mime = "application/json", run = "bat" },
	{ mime = "*/{xml,javascript,x-wine-extension-ini}", run = "bat" },
]
```

`bat` reads its own configuration file, so set your theme there instead (`bat --config-file` shows the path). Note the preview only wraps at the preview pane width; long lines are truncated.

If `bat` fails to preview a file, the plugin falls back to Yazi's built-in code previewer.

## License

MIT, see [LICENSE](LICENSE).
