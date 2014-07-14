linterPath = atom.packages.getLoadedPackage("linter").path
Linter = require "#{linterPath}/lib/linter"

class LinterPerl extends Linter
  @syntax: ["source.perl"]
  linterName: "perl"

  # Reset this in constructor because $SHELL isn't extracted in spawning.
  cmd: "$SHELL perl -MO=Lint,all"

  regex: "(?<message>.*) at .* line (?<line>\\d+).*\\n"
  errorStream: "stderr"

  constructor: (editor) ->
    super(editor)

    @cmd = "#{process.env.SHELL} -l perl -MO=Lint,all"

    atom.config.observe "linter-perl.perlExecutablePath", =>
      @executablePath = atom.config.get "linter-perl.perlExecutablePath"

  destroy: ->
    atom.config.unobserve "linter-perl.perlExecutablePath"

module.exports = LinterPerl
