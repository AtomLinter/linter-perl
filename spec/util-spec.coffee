util = require "../lib/util"

describe "util", ->

  it "clone()", ->
    obj1 = a: 100, b: {c: 200}
    obj2 = util.clone(obj1)
    expect(obj2).toEqual(obj1)
    obj2.b.c = 0
    expect(obj1.b.c).toEqual(200)
    expect(obj2.b.c).toEqual(0)

  it "findIndex()", ->
    a = [1, 2, 3, 4]
    idx = util.findIndex(a, (v) -> v % 2 is 0)
    expect(idx).toEqual(1)
