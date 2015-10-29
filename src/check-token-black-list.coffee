http = require 'http'

class CheckTokenBlackList
  constructor: (options={}) ->
    {@cache} = options

  do: (request, callback) =>
    {uuid,token} = request.metadata.auth

    @cache.exists "#{uuid}:#{token}", (error, result) =>
      code = 204
      code = 403 if result == 1

      response =
        responseId: request.metadata.responseId
        code: code
        status: http.STATUS_CODES[code]

      callback null, response


module.exports = CheckTokenBlackList
