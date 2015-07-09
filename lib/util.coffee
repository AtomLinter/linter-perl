path = require "path"

findIndex = (values, fn) ->
  i = 0
  len = values.length
  while i < len
    return i if fn values[i]
    i++
  return -1

clone = (obj) -> JSON.parse(JSON.stringify(obj))

# Determine the root directory of the active text editor.
determineRootDirectory = (textEditor) ->
  activeFilePath = textEditor.getPath()
  dirs = atom.project.getDirectories()
  # https://github.com/atom/atom/blob/v0.194.0/src/project.coffee#L303
  idx = findIndex dirs, (dir) -> dir.contains(activeFilePath)
  if idx >= 0
    return dirs[idx].getPath()
  else
    return path.dirname(activeFilePath)

module.exports =
  clone: clone
  findIndex: findIndex
  determineRootDirectory: determineRootDirectory
