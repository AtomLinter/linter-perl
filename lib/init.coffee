LinterPerl = require "./linter-perl"

module.exports =

  config:
    perlExecutablePath:
      type: "string"
      default: ""
      description: """
      DEPRECATED: use 'executablePath'
      """
    executablePath:
      type: "string"
      default: ""
      description: """
      The absolute directory path containing interpreter binaries.
      (ex. "/Users/user/.plenv/shims")
      """
    executeCommandViaShell:
      type: "boolean"
      default: false
      description: """
      Is the command executed via `$SHELL -l`?
      This is useful when PATH is setup in .bash_profile, etc.
      If true, executablePath option is ignored.
      """
    autoDetectCarton:
      type: "boolean"
      default: false
      description: """
      Is carton enabled if there are both "cpanfile.snapshot" and "local/"
      in the current root directory?
      """
    additionalPerlOptions:
      type: "string"
      default: ""
      description: """
      This is passed to the perl interpreter directly.
      """
    incPathsFromProjectPath:
      type: "array"
      default: [".", "lib"]
      items:
        type: "string"
      description: """
      DEPRECATED: use 'incPathsFromProjectRoot'
      """
    incPathsFromProjectRoot:
      type: "array"
      default: [".", "lib"]
      items:
        type: "string"
      description: """
      Relative include paths from the current root directory.
      """
    lintOptions:
      type: "string"
      default: "all"
      description: """
      B::Lint options; "-MO=Lint,HERE".
      (ex. "all,no-bare-subs,no-context")
      """

  activate: ->
    @linterPerl = new LinterPerl @config

  deactivate: ->
    @linterPerl.destructor()
    @linterPerl = null

  provideLinter: ->
    @linterPerl
