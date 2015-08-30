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
  scope: "file"
  lintOnFly: true

  #---

  config: {}

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
    new Promise (resolve, reject) =>
      buf = []
      stdout = (output) -> buf.push output
      stderr = (output) -> buf.push output
      exit = (code) ->
        results = []
        for line in buf.join("\n").split("\n")
          m = line.match RE
          continue unless m and m.length is 4
          [unused, message, filePath, lineNum] = m
          results.push
            type: 'Error'
            text: message
            filePath: filePath
            range: [
              [lineNum-1, 0]
              [lineNum-1, textEditor.getBuffer().lineLengthForRow(lineNum-1)]
            ]
        resolve results

      filePath = textEditor.getPath()
      rootDirectory = util.determineRootDirectory(textEditor)
      {command, args} = @buildCommand filePath, rootDirectory
      process = new BufferedProcess {command, args, stdout, stderr, exit}
      process.onWillThrowError ({error, handle}) ->
        atom.notifications.addError "Failed to run #{command}.",
          detail: error.message
          dismissable: true
        handle()
        resolve []

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

    # carton support
    if @config.autoDetectCarton
      isCartonUsed = \
        fs.existsSync(path.join(rootDirectory, "cpanfile.snapshot")) \
        and fs.existsSync(path.join(rootDirectory, "local"))
      cmd = ["carton", "exec", "--"].concat cmd if isCartonUsed

    # plenv/perlbrew support
    if @config.executeCommandViaShell
      cmd = [process.env.SHELL, "-lc", cmd.join(" ")]

    [command, args...] = cmd
    {command, args}
