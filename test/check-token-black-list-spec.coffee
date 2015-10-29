redis = require 'fakeredis'
uuid  = require 'uuid'
CheckTokenBlackList = require '../src/check-token-black-list'

describe 'CheckTokenBlackList', ->
  beforeEach ->
    @redisKey = uuid.v1()
    @sut = new CheckTokenBlackList cache: redis.createClient(@redisKey)
    @cache = redis.createClient @redisKey

  describe '->do', ->
    describe 'when the uuid/token combination is not in the blacklist', ->
      beforeEach (done) ->
        request =
          metadata:
            responseId: 'asdf'
            auth:
              uuid:  'barber-slips'
              token: 'Just a little off the top'

        @sut.do request, (error, @response) => done error

      it 'should respond with a 204', ->
        expect(@response).to.deep.equal
          responseId: 'asdf'
          code: 204
          status: 'No Content'

    describe 'when a different uuid/token combination is not in the blacklist', ->
      beforeEach (done) ->
        request =
          metadata:
            responseId: 'some-response'
            auth:
              uuid:  'beak'
              token: "(By which we mean a bird's horny projecting jaws)"

        @sut.do request, (error, @response) => done error

      it 'should respond with a 204', ->
        expect(@response).to.deep.equal
          responseId: 'some-response'
          code: 204
          status: 'No Content'

    describe 'when a uuid/token combination is in the blacklist', ->
      beforeEach (done) ->
        @cache.set 'dolphin:are-they-legitimate', '', done

      beforeEach (done) ->
        request =
          metadata:
            responseId: "You'll swim with the fishes (Except they're actually mammals)!"
            auth:
              uuid:  'dolphin'
              token: 'are-they-legitimate'

        @sut.do request, (error, @response) => done error

      it 'should respond with a 403', ->
        expect(@response).to.deep.equal
          responseId: "You'll swim with the fishes (Except they're actually mammals)!"
          code: 403
          status: 'Forbidden'

    describe 'when a different uuid/token combination is in the blacklist', ->
      beforeEach (done) ->
        @cache.set 'got-too-extreme:sickblast-it-to-the-max-brotimes', '', done

      beforeEach (done) ->
        request =
          metadata:
            responseId: 'extreme'
            auth:
              uuid:  'got-too-extreme'
              token: 'sickblast-it-to-the-max-brotimes'

        @sut.do request, (error, @response) => done error

      it 'should respond with a 403', ->
        expect(@response).to.deep.equal
          responseId: 'extreme'
          code: 403
          status: 'Forbidden'
