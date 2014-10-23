linterPath = atom.packages.getLoadedPackage("linter").path
Linter = require "#{linterPath}/lib/linter"
fs = require "fs"
path = require "path"

class LinterPerl extends Linter
  @syntax: ["source.perl"]
  linterName: "perl"

  # Reset this on changing settings
  cmd: "perl -MO=Lint,all"

  regex: "(?<message>.*) at .* line (?<line>\\d+).*\\n"
  errorStream: "stderr"

  # configurable properties
  detectsCarton: true
  executesCommandViaShell: false
  additionalPerlOptions: null
  incPathsFromProjectPath: ["lib"]

  setupCommand: ->
    project_path = atom.project.getPath()

    # build perl options
    opts = do =>
      paths = @incPathsFromProjectPath.map (p) ->
        "-I" + path.join(project_path, p)
      (if @additionalPerlOptions? then @additionalPerlOptions + " " else "") \
        + paths.join(" ")

    # base command
    cmd = "perl #{opts} -MO=Lint,all"

    # carton support
    if @detectsCarton
      useCarton = fs.existsSync(path.join(project_path, "cpanfile.snapshot")) \
        and fs.existsSync(path.join(project_path, "local"))
      cmd = "carton exec -- #{cmd}" if useCarton

    # plenv/perlbrew support
    if @executesCommandViaShell
      cmd = "#{process.env.SHELL} -l -- #{cmd}"

    @cmd = cmd

  constructor: (editor) ->
    super(editor)

    do (name="linter-perl.autoDetectCarton") =>
      atom.config.observe name, =>
        @detectsCarton = atom.config.get name
        @detectsCarton ?= true
        @setupCommand()

    do (name="linter-perl.executeCommandViaShell") =>
      atom.config.observe name, =>
        @executesCommandViaShell = atom.config.get name
        @setupCommand()

    do (name="linter-perl.perlExecutablePath") =>
      atom.config.observe name, =>
        @executablePath = atom.config.get name

    do (name="linter-perl.additionalPerlOptions") =>
      atom.config.observe name, =>
        @additionalPerlOptions = atom.config.get name
        @setupCommand()

    do (name="linter-perl.incPathsFromProjectPath") =>
      atom.config.observe name, =>
        @incPathsFromProjectPath = atom.config.get name
        @incPathsFromProjectPath ?= ["lib"]
        @setupCommand()

  destroy: ->
    atom.config.unobserve "linter-perl.#{name}" for name in [
      "autoDetectCarton"
      "executeCommnadViaShell"
      "perlExecutablePath"
      "incPathsFromProjectPath"
    ]

module.exports = LinterPerl
