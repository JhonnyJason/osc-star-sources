############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("sessionauthmodule")
#endregion

############################################################
import * as decay from "memory-decay"
import * as sess from "thingy-session-utils"
import * as keys from "./servicekeysmodule.js"
# import * as secUtl from "secret-manager-crypto-utils"
import * as validatableStamp from "./validatabletimestampmodule.js"

############################################################
validCodeMemory = null
authCodeValidityMS = 180000

############################################################
export initialize = ->
    log "initialize"
    c = allModules.configmodule
    if c.authCodeValidityMS? then authCodeValidityMS = c.authCodeValidityMS
    decay.setDefaultDecayMS(authCodeValidityMS)
    
    validCodeMemory = decay.makeForgetable({})
    return

############################################################
export startSession = (clientId, request) ->
    log "startSession"
    seedHex = await keys.getEntropySeed(clientId)
    authCode = await sess.createAuthCode(seedHex, request)
    olog { authCode }

    sessionInfo = {clientId, seedHex}

    validCodeMemory[authCode] = sessionInfo
    validCodeMemory.letForget(authCode)
    return

export startSessionIndirectly = (publicKey) ->
    log "startSessionIndirectly"
    sessionSeed = await secUtl.createRandomLengthSalt()

    try response = await client.shareSecretTo(publicKey, "sessionSeed", sessionSeed)
    catch err then throw new Error("Could not share sessionSeed to client! - #{err.message}")

    try clientSeed = await client.getSecretFrom("sessionSeed", publicKey)
    catch err then throw new Error("Could not get sessionSeed from client! - #{err.message}")

    seed = clientSeed + sessionSeed
    authCode = await secUtl.sha256Hex(seed)
    olog { authCode }

    sessionInfo = {publicKey, clientSeed, sessionSeed}

    validCodeMemory[authCode] = sessionInfo
    validCodeMemory.letForget(authCode)
    return

export getOrThrow = (authCode) ->
    session = validCodeMemory[authCode]
    throw new Error("Invalid authCode!") unless session?

    delete validCodeMemory[authCode]
    return session

export generateNextAuthCodeOld = (session, content) ->
    log "generateNextAuthCodeOld"
    olog {session}
    authCode = await secUtl.sha256Hex(session.clientSeed + session.sessionSeed + content)
    validCodeMemory[authCode] = session
    validCodeMemory.letForget(authCode)
    return

export generateNextAuthCode = (session, request) ->
    log "generateNextAuthCode"
    olog {session}
    authCode = await sess.createAuthCode(session.seedHex, request)
    validCodeMemory[authCode] = session
    validCodeMemory.letForget(authCode)
    return
