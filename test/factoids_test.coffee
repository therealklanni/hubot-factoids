chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

describe 'factoids', ->
  beforeEach ->
    @robot =
      hear: sinon.spy()
      respond: sinon.spy()
      brain:
        on: sinon.spy()
      router:
        get: sinon.spy()

    @msg =
      send: sinon.spy()
      reply: sinon.spy()
      message:
        user:
          name: 'sinon'

    require('../src/factoids')(@robot)

  it 'registers a hear listener', ->
    expect(@robot.hear).to.have.been.calledWith(/^!([\w\s-]{2,}\w)( @.+)?/i)

  describe 'registers respond listeners', ->
    it 'responds to learn command', ->
      expect(@robot.respond).to.have.been.calledWith(/learn (.{3,}) = (.+)/i)

      @msg.match = ['', 'test', '123']
      @robot.respond.args[0][1](@msg)
      expect(@msg.send).to.have.been.calledWith('OK sinon, test is now 123')

    it 'responds to learn command with substitution', ->
      expect(@robot.respond).to.have.been.calledWith(/learn (.{3,}) =~ s\/(.+)\/(.+)\/(.*)/i)

      @msg.match = ['', 'test', '123', '234', 'gi']
      @robot.respond.args[1][1](@msg)
      expect(@msg.send).to.have.been.calledWith('OK sinon, test is now 234')

    it 'responds to forget command', ->
      expect(@robot.respond).to.have.been.calledWith(/forget (.{3,})/i)

      @msg.match = ['', 'test']
      @robot.respond.args[2][1](@msg)
      expect(@msg.reply).to.have.been.calledWith('OK, forgot test')

    it 'responds to factoids command', ->
      expect(@robot.respond).to.have.been.calledWith(/factoids/i)

      @robot.respond.args[3][1](@msg)
      expect(@msg.reply).to.have.been.calledWith('http://not-yet-set/hubot/factoids')

    it 'responds to alias command', ->
      expect(@robot.respond).to.have.been.calledWith(/alias (.{3,}) = (.{3,})/i)

      @msg.match = ['', 'blah', 'test']
      @robot.respond.args[4][1](@msg)
      expect(@msg.send).to.have.been.calledWith('OK sinon, aliased blah to test')

    it 'responds to drop command', ->
      expect(@robot.respond).to.have.been.calledWith(/drop (.{3,})/i)

      @msg.match = ['', 'blah']
      @robot.respond.args[5][1](@msg)
      expect(@msg.send).to.have.been.calledWith('OK, blah has been dropped.')
