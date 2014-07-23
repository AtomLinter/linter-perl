linter-perl package
===================

This linter plugin for [Linter](https://github.com/AtomLinter/Linter) provides an interface to perl.
It will be used with files that have the "Perl" syntax.

## Installation

* Install [Perl 5](http://www.perl.org/).
* `apm install linter` (if you didn't install Linter).
* `apm install linter-perl`

## Settings
You can configure linter-perl by editing ~/.atom/config.cson (choose Open Your Config in Atom menu):

```
"linter-perl":
  "perlExecutablePath": null # perl path. run 'which perl' to find the path
  "executeCommandViaShell": false # If it is true, the command is executed via `$SHELL -l`
  "autoDetectCarton": true # If it is true, and "cpanfile.snapshot" and "local/" exist, carton command is used.
  "additionalPerlOptions": "-Ilib" # This is passed to the perl interpreter.
```

### plenv Support

There are three ways to use this package with [plenv](https://github.com/tokuhirom/plenv):

- Open a project by `atom .` in your shell.
- Otherwise (e.g. drag & drop),
  - set `"/absolute/path/to/.plenv/shims"` to `perlExecutablePath` (this way is not portable)
  - set `true` to `executeCommnadViaShell` (`perlExecutablePath` is ignored)

[Perlbrew](http://perlbrew.pl/) is not tested, but those methods could be used.

## Contributing
If you would like to contribute enhancements or fixes, please do the following:

1. Fork the plugin repository.
1. Hack on a separate topic branch created from the latest `master`.
1. Commit and push the topic branch.
1. Make a pull request.
1. welcome to the club

Please note that modifications should follow these coding guidelines:

- Indent is 2 spaces.
- Code should pass coffeelint linter.
- Vertical whitespace helps readability, don’t be afraid to use it.

Thank you for helping out!
