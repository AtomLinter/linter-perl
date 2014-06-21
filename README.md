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
```

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
