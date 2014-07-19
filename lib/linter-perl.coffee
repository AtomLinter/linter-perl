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

  setupCommand: ->
    cmd = "perl -MO=Lint,all"
    if @detectsCarton
      useCarton = fs.existsSync(path.join(@cwd, "cpanfile.snapshot")) \
        and fs.existsSync(path.join(@cwd, "local"))
      cmd = "carton exec -- #{cmd}" if useCarton
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
        @runsCommandViaShell = atom.config.get name
        @setupCommand()

    do (name="linter-perl.perlExecutablePath") =>
      atom.config.observe name, =>
        @executablePath = atom.config.get name

  destroy: ->
    atom.config.unobserve "linter-perl.#{name}" for name in [
      "autoDetectCarton", "executeCommnadViaShell", "perlExecutablePath"
    ]

module.exports = LinterPerl
