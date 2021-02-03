# `SodaPop` [![Build Status](https://travis-ci.org/repla-app/SodaPop.svg?branch=master)](https://travis-ci.org/repla-app/SodaPop)

`SodaPop` is the plugin manager for [Repla](https://repla.app/). `SodaPop` loads Repla plugins from disk and provides 

## Compiling

`SodaPop` uses [Carthage](https://github.com/Carthage/Carthage), so before compiling, run `carthage update`.

## Initializing

``` swift
PluginsManager(pluginsPaths: [Directory.builtInPlugins.path(),
                              Directory.applicationSupportPlugins.path()],
               copyTempDirectoryURL: Directory.caches.URL(),
               defaults: UserDefaults.standard,
               fallbackDefaultNewPluginName: fallbackDefaultNewPluginName,
               userPluginsPath: Directory.applicationSupportPlugins.path(),
               builtInPluginsPath: Directory.builtInPlugins.path())
```

- `pluginsPath`: All paths to load plugins from
- `copyTempDirectoryURL`: Temporary directory to use for duplicating plugins
- `defaults`: Storage for plugin preferences
- `fallbackDefaultNewPluginName`: Default new plugin if no user preference is found
- `userPluginsPath`: Path for plugins defined as user plugins (mutable plugins)
- `builtInPluginsPath`: Path for plugins defined as built-in (immutable plugins)
