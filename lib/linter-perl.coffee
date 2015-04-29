linterPath = atom.packages.getLoadedPackage("linter").path
Linter = require "#{linterPath}/lib/linter"
fs = require "fs"
path = require "path"
util = require "./util"

module.exports =
class LinterPerl extends Linter

  @PACKAGE_NAME: "linter-perl"

  @DEFAULT_CONFIG:
    perlExecutablePath: null
    executeCommandViaShell: false
    audoDetectCarton: true
    additionalPerlOptions: null
    incPathsFromProjectPath: [".", "lib"]
    lintOptions: "all"

  @DEFAULT_COMMAND: "perl -MO=Lint,all"

  @syntax: ["source.perl"]

  linterName: "perl"

  errorStream: "stderr"

  regex: "(?<message>.*) at .* line (?<line>\\d+)"

  cmd: @DEFAULT_COMMAND

  # config state
  config: util.clone(@DEFAULT_CONFIG)

  # build a lint command from the current states.
  buildCommand: (rootDirectory) ->
    cmd = "perl -MO=Lint"

    # perl -MO=Lint,all,...
    if @config.lintOptions
      cmd += "," + @config.lintOptions

    # perl -I. -Ilib ...
    if @config.incPathsFromProjectPath.length > 0
      cmd += " " + @config.incPathsFromProjectPath
        .map (p) -> "-I" + path.join(rootDirectory, p)
        .join " "

    # perl --any --options
    if @config.additionalPerlOptions
      cmd += " " + @config.additionalPerlOptions

    # carton support
    if @config.audoDetectCarton
      isCartonUsed = \
        fs.existsSync(path.join(rootDirectory, "cpanfile.snapshot")) \
        and fs.existsSync(path.join(rootDirectory, "local"))
      cmd = "carton exec -- #{cmd}" if isCartonUsed

    # plenv/perlbrew support
    if @config.executeCommandViaShell
      cmd = "#{process.env.SHELL} -l #{cmd}"
      @executablePath = null
    else if @config.perlExecutablePath
      @executablePath = @config.perlExecutablePath

    return cmd

  # override
  lintFile: (filePath, callback) ->
    rootDirectory = util.determineRootDirectory()
    if rootDirectory
      @cmd = @buildCommand(rootDirectory)
    else
      @cmd = @constructor.DEFAULT_COMMAND
    console.log @cmd
    super filePath, callback

  constructor: (editor) ->
    super editor
    for name, defaultValue of @constructor.DEFAULT_CONFIG
      keyPath = "#{@constructor.PACKAGE_NAME}.#{name}"
      atom.config.observe keyPath, (value) =>
        @config[name] = value
        @config[name] ?= defaultValue
