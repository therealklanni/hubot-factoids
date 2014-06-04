class Factoids
  constructor: (@robot) ->
    @data ?= {}

    @robot.brain.on 'loaded', =>
      @data = @robot.brain.data.factoids ?= {}

  set: (key, value, who, resolveAlias) ->
    key = key.trim()
    value = value.trim()
    fact = @get key, resolveAlias

    if typeof fact is 'object'
      fact.history ?= []
      hist =
        date: Date()
        editor: who
        oldValue: fact.value
        newValue: value

      fact.history.push hist
      fact.value = value
      if fact.forgotten? then fact.forgotten = false
    else
      fact =
        value: value
        popularity: 0

    @data[key.toLowerCase()] = fact

  get: (key, resolveAlias = true) ->
    fact = @data[key.toLowerCase()]
    alias = fact?.value?.match /^@([^@].+)$/i
    if resolveAlias and alias?
      fact = @get alias[1]
    fact

  forget: (key) ->
    fact = @get key

    if fact
      fact.forgotten = true

  drop: (key) ->
    key = key.toLowerCase()
    if @get key, false
      delete @data[key]
    else false

module.exports = Factoids
