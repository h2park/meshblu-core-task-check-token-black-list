http = require 'http'

class CheckTokenBlackList
  constructor: (options={}) ->
    {@cache} = options

  do: (request, callback) =>
    unless request.metadata.auth?
      return @_doCallback request, 422, callback

    {uuid,token} = request.metadata.auth

    @cache.exists "#{uuid}:#{token}", (error, result) =>
      return callback error if error?

      code = 204
      code = 401 if result

      @_doCallback request, code, callback

  _doCallback: (request, code, callback) =>
    response =
      metadata:
        responseId: request.metadata.responseId
        code: code
        status: http.STATUS_CODES[code]
    callback null, response

module.exports = CheckTokenBlackList
