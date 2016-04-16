{CompositeDisposable, BufferedProcess} = require "atom"
pkg = require "../package.json"
fs = require "fs"
path = require "path"
{deprecate} = require "grim"
_ = {
  isEqual: require "lodash/lang/isEqual"
}
util = require "./util"

module.exports = class LinterPerl

  grammarScopes: ["source.perl"]
  name: "B::Lint"
  scope: "file"
  lintOnFly: true

  #---

  config: {}

  BLintFound: {}

  DEPRECATED_OPTIONS =
    perlExecutablePath: "executablePath"
    incPathsFromProjectPath: "incPathsFromProjectRoot"

  constructor: (configSchema) ->
    @subscriptions = new CompositeDisposable
    for name of configSchema
      keyPath = "#{pkg.name}.#{name}"
      value = atom.config.get keyPath
      if DEPRECATED_OPTIONS[name]
        unless _.isEqual value, configSchema[name].default
          deprecate """
          #{pkg.name}.#{name} is deprecated.
          Please use #{pkg.name}.#{DEPRECATED_OPTIONS[name]} in your config.
          """
        name = DEPRECATED_OPTIONS[name]
      @config[name] = value
      @subscriptions.add atom.config.observe keyPath, (value) =>
        @config[name] = value

  destructor: ->
    @subscriptions.dispose()

  RE = /(.*) at (.*) line (\d+)/

  lint: (textEditor) ->
    rootDirectory = util.determineRootDirectory(textEditor)

    lint = (resolve, reject) =>
      buf = []
      stdout = (output) -> buf.push output
      stderr = (output) -> buf.push output
      exit = (code) ->
        results = []
        for line in buf.join("\n").split("\n")
          m = line.match RE
          continue unless m and m.length is 4
          [unused, message, filePath, lineNum] = m
          range = null
          buffer = textEditor.getBuffer()
          if lineNum <= buffer.getLineCount()
            range = [
              [lineNum-1, 0]
              [lineNum-1, buffer.lineLengthForRow(lineNum-1)]
            ]
          if range and message?.length
            results.push {
              type: 'Error'
              text: message
              filePath
              range
            }
        resolve results

      filePath = textEditor.getPath()
      {command, args} = @buildCommand filePath, rootDirectory
      options = cwd: rootDirectory
      process = new BufferedProcess \
        {command, args, stdout, stderr, exit, options}
      process.onWillThrowError ({error, handle}) ->
        atom.notifications.addError "Failed to run #{command}.",
          detail: error.message
          dismissable: true
        handle()
        resolve []

    new Promise (resolve, reject) =>
      @checkBLint rootDirectory
        .then -> lint resolve, reject
        .catch reject

  checkBLint: (rootDirectory) ->
    new Promise (resolve, reject) =>
      resolve true if @BLintFound[rootDirectory]
      {command, args} = @buildCommandToCheckBLint rootDirectory
      exit = (code) =>
        @BLintFound[rootDirectory] = !code
        if @BLintFound[rootDirectory]
          resolve true
        else
          reject
            toString: -> "B::Lint not found."
            stack: """
            You should make sure to install B::Lint.
            From 5.20, B::Lint is removed from core modules.
            """
      options = cwd: rootDirectory
      process = new BufferedProcess {command, args, exit, options}

  # build a lint command from the current states.
  buildCommand: (filePath, rootDirectory) ->
    cmd = ["perl", "-MO=Lint"]

    # perl -MO=Lint,all,...
    if @config.lintOptions
      cmd[1] += "," + @config.lintOptions

    # perl -I. -Ilib ...
    if @config.incPathsFromProjectRoot.length > 0
      cmd = cmd.concat @config.incPathsFromProjectRoot.map (p) ->
        "-I" + path.join(rootDirectory, p)

    # perl --any --options
    if @config.additionalPerlOptions
      cmd = cmd.concat @config.additionalPerlOptions

    # perl -MO=Lint file
    cmd.push filePath

    [command, args...] = @enhancePerlCommand cmd, rootDirectory
    {command, args}

  buildCommandToCheckBLint: (rootDirectory) ->
    [command, args...] = @enhancePerlCommand \
      ["perl", "-MB::Lint", "-e", "1"], rootDirectory
    {command, args}

  enhancePerlCommand: (cmd, rootDirectory) ->
    # carton support
    if @config.autoDetectCarton
      isCartonUsed = \
        fs.existsSync(path.join(rootDirectory, "cpanfile.snapshot")) \
        and fs.existsSync(path.join(rootDirectory, "local"))
      cmd = ["carton", "exec", "--"].concat cmd if isCartonUsed

    # plenv/perlbrew support
    if @config.executeCommandViaShell
      cmd = [process.env.SHELL, "-lc", cmd.join(" ")]

    cmd
