# `SodaPop` ![Status](https://github.com/robenkleene/sodapop/actions/workflows/ci.yml/badge.svg) ![Status](https://github.com/robenkleene/sodapop/actions/workflows/release.yml/badge.svg)

`SodaPop` is the plugin manager for [Repla](https://repla.app/). `SodaPop` loads Repla [plugins](https://repla.app/plugins/) from disk and provides functionality for managing plugins.

## Compiling

`SodaPop` uses [Carthage](https://github.com/Carthage/Carthage), so before compiling, run `carthage update`.

## Initialization

``` swift
let pluginsManager = PluginsManager(pluginsPaths: [Directory.builtInPlugins.path(),
                                                   Directory.applicationSupportPlugins.path()],
                                    copyTempDirectoryURL: Directory.caches.URL(),
                                    defaults: UserDefaults.standard,
                                    fallbackDefaultNewPluginName: fallbackDefaultNewPluginName,
                                    userPluginsPath: Directory.applicationSupportPlugins.path(),
                                    builtInPluginsPath: Directory.builtInPlugins.path())
```

- `pluginsPath`: Paths to load plugins from
- `copyTempDirectoryURL`: Temporary directory for duplicating plugins
- `defaults`: Storage for plugin preferences
- `fallbackDefaultNewPluginName`: Default new plugin if no user preference is found
- `userPluginsPath`: Path for plugins defined as user plugins (mutable plugins)
- `builtInPluginsPath`: Path for plugins defined as built-in (immutable plugins)

## Examples

Get all plugins:

``` swift
let plugins = pluginsManager.plugins
```

Get a plugin by name:

``` swift
let plugin = pluginsManager.plugin(withName: name)
```
