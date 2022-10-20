############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("sessionauthmodule")
#endregion

############################################################
export initialize = ->
    log "initialize"
    #Implement or Remove :-)
    return


# ############################################################
# specialAuth = null
# validCodeMemory = {}

# ############################################################
# authmodule.initialize = ->
#     log "authmodule.initialize"

#     specialAuth = cfg.specialAuth
#     if !specialAuth? then specialAuth = {}

#     keys = Object.keys(specialAuth)
#     for key in keys
#         specialAuth[key] = specialAuthFunctionFor(specialAuth[key])

#     Object.freeze(specialAuth)
#     return

# ############################################################
# specialAuthFunctionFor = (typeString) ->
#     if typeString == "masterSignature" then return isMasterSignature
#     if typeString == "knownClientSignature" then return isKnownClientSignature
#     throw new Error("Invalid specialAuth typeString in config: '"+typeString+"' !")
#     return

# isMasterSignature = (req) ->
#     log "isMasterSignature"
#     data = req.body
#     route = req.path
    
#     idHex = cfg.masterPublicKey
    
#     olog data
#     olog {route}

#     assertValidTimestamp(data.timestamp)
    
#     sigHex = data.signature
#     if !sigHex then throw new Error("No Signature!")
#     delete data.signature
#     content = route+JSON.stringify(data)

#     try
#         verified = await secUtl.verify(sigHex, idHex, content)
#         if !verified then throw new Error("Invalid Signature!")
#         return true
#     catch err then throw new Error("Error on Verify! " + err)
#     return false    

# isKnownClientSignature = (req) ->
#     log "isKnownClientSignature"
#     data = req.body
#     route = req.path
    
#     idHex = data.publicKey
#     throw new Error("Client unknown!") unless knownClients[idHex]
    
#     olog data
#     olog {route}

#     assertValidTimestamp(data.timestamp)
    
#     sigHex = data.signature
#     if !sigHex then throw new Error("No Signature!")
#     delete data.signature
#     content = route+JSON.stringify(data)

#     try
#         verified = await secUtl.verify(sigHex, idHex, content)
#         if !verified then throw new Error("Invalid Signature!")
#         return true
#     catch err then throw new Error("Error on Verify! " + err)
#     return false

# ############################################################
# isValidAuthCode = (code) ->
#     log "isValidAuthCode"
#     olog {code}
#     throw new Error("Invalid authCode!") unless validCodeMemory[code]?
#     sessionInfo = validCodeMemory[code]
#     delete validCodeMemory[code]

#     session.putInfo(code, sessionInfo)
#     return true

# generateNewAuthCode = (oldCode, req) ->
#     log "generateNewAuthCode"
#     olog {oldCode}
#     if validCodeMemory[oldCode]?
#         log "oldCode still available in validCodeMemory!"
#         delete validCodeMemory[oldCode]
#         return
#     try
#         sessionInfo = session.getInfo(oldCode)
#         newCode = "..."
#         olog {newCode}
#         ## TODO generae real next Code
#         validCodeMemory[newCode] = sessionInfo
#         ## TODO letForget
#     catch err then log err.stack
#     return

# ############################################################
# startSession = (publicKey) ->
#     log "startSession"
#     sessionSeed = await secUtl.createRandomLengthSalt()
#     response = await client.shareSecretTo(publicKey, "sessionSeed", sessionSeed)
#     olog response
#     clientSeed = await client.getSecretFrom("sessionSeed", publicKey)
    
#     seed = clientSeed + sessionSeed
#     authCode = await secUtl.sha256Hex(seed)
#     olog { authCode }

#     sessionInfo = {publicKey}

#     validCodeMemory[authCode] = sessionInfo
#     decay.letForget(authCode, validCodeMemory, decayMS)
#     return
