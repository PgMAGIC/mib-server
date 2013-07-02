http = require('http')
dns = require('dns')
Q = require('q')


getServerIp = () ->
  deferred = Q.defer()
  if process.env.SERVER_IP
    Q.fcall () ->
      process.env.SERVER_IP
  else
    dns.lookup(require('os').hostname(),  (err, add, fam) ->
      if err
        deferred.reject new Error(err)
      else
        deferred.resolve add
    )
    deferred.promise


module.exports.getServerIp = getServerIp