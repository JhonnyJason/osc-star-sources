############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("authenticationmodule")
#endregion

############################################################
import * as dataCache from "cached-persistentstate"
import * as secUtl from "secret-manager-crypto-utils"
import * as timestampVerifier from "./validatabletimestampmodule.js"
import * as blocker from "key-block"

import { authenticateSession } from "./sessionauthmodule.js" 
import * as serviceCrypto from "./servicekeysmodule.js"

############################################################
toServeStore = null
toServe = null

############################################################
masterKeyId = ""

############################################################
export initialize = ->
    c = allModules.configmodule

    if c.masterKeyId then masterKeyId = c.masterKeyId

    if c.validationTimeFrameMS then tfMS = c.validationTimeFrameMS
    else tfMS = 180000

    blocker.setBlockingTimeMS(3*tfMS)
    
    toServeStore = dataCache.load("toServeStore")
    if toServeStore.meta? then await validateToServeStore()
    else
        toServeStore.meta = {}
        toServeStore.toServe = {}
    toServe = toServeStore.toServe
    return

############################################################
validateToServeStore = ->
    log "validateToServeStore"
    meta = toServeStore.meta
    signature = meta.serverSig
    if !signature then throw new Error("No signature in toServeStore.meta !")
    meta.serverSig = ""
    jsonString = JSON.stringify(toServeStore)
    meta.serverSig = signature
    if(await serviceCrypto.verify(signature, jsonString)) then return
    else throw new Error("Invalid Signature in toServeStore.meta !")

signAndSaveToServeStore = ->
    log "signAndSaveToServeStore"
    toServeStore.meta.serverSig = ""
    toServeStore.meta.serverPub = serviceCrypto.getPublicKeyHex()
    jsonString = JSON.stringify(toServeStore)
    signature = await serviceCrypto.sign(jsonString)
    toServeStore.meta.serverSig = signature
    dataCache.save("toServeStore")
    return

############################################################
export getMasterKeyId = -> masterKeyId

############################################################
export assertClientIsToBeServed = (idHex) ->
    if !toServe[idHex] then throw new Error("Client #{idHex} is not to be served!")
    return

############################################################
export addClientToServe = (idHex) ->
    toServe[idHex] = true
    await signAndSaveToServeStore()
    return

export removeClientToServe = (idHex) ->
    delete toServe[idHex]
    await signAndSaveToServeStore()
    return

export getClientsToServe = -> Object.keys(toServe)


