linterPath = atom.packages.getLoadedPackage("linter").path
Linter = require "#{linterPath}/lib/linter"
fs = require "fs"
path = require "path"

class LinterPerl extends Linter
  @syntax: ["source.perl"]
  linterName: "perl"

  # Reset this in constructor
  cmd: "perl -MO=Lint,all"

  regex: "(?<message>.*) at .* line (?<line>\\d+).*\\n"
  errorStream: "stderr"

  constructor: (editor) ->
    super(editor)

    useCarton = fs.existsSync(path.join(@cwd, "cpanfile.snapshot")) \
      and fs.existsSync(path.join(@cwd, "local"))
    bin = if useCarton then "carton exec -- perl" else "perl"
    @cmd = "#{process.env.SHELL} -l -- #{bin} -MO=Lint,all"

    atom.config.observe "linter-perl.perlExecutablePath", =>
      @executablePath = atom.config.get "linter-perl.perlExecutablePath"

  destroy: ->
    atom.config.unobserve "linter-perl.perlExecutablePath"

module.exports = LinterPerl
