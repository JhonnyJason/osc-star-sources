############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("authenticationmodule")
#endregion

############################################################
import * as secUtl from "secret-manager-crypto-utils"
import * as timestampVerifier from "./validatabletimestampmodule.js"
import * as blocker from "key-block"

import { authenticateSession } from "./sessionauthmodule.js" 


############################################################
export initialize = ->
    c = allModules.configmodule
    if c.validationTimeFrameMS then tfMS = c.validationTimeFrameMS
    else tfMS = 180000
    blocker.setBlockingTimeMS(3*tfMS)
    return

############################################################
toServeList = {}

############################################################
masterKeyId = ""

############################################################
#region internalFunctions

authenticateMaster = (req) ->
    log "authenticateClient"
    data = req.body
    sigHex = data.signature
    timestamp = data.timestamp

    if !timestamp then throw new Error("No Timestamp!") 
    if !sigHex then throw new Error("No Signature!")

    idHex = masterKeyId

    olog data
    # olog sigHex
    # olog timestamp

    # assert that the signature has not been used yet
    blocker.blockOrThrow(sigHex)
    # will throw if timestamp is not valid 
    timestampVerifier.assertValidity(timestamp) 

    delete data.signature
    content = req.path+JSON.stringify(data)
    verified = await secUtl.verify(sigHex, idHex, content)
    
    if !verified then throw new Error("Invalid Signature!")
    return


############################################################
authenticateClient = (req) ->
    log "authenticateClient"
    data = req.body
    idHex = data.publicKey
    sigHex = data.signature
    timestamp = data.timestamp

    if !timestamp then throw new Error("No Timestamp!") 
    if !sigHex then throw new Error("No Signature!")
    if !idHex then throw new Error("No PublicKey!")

    olog data
    # olog idHex
    # olog sigHex
    # olog timestamp

    # assert that the signature has not been used yet
    blocker.assertAndBlock(sigHex)
    # will throw if timestamp is not valid 
    timestampVerifier.assertValidity(timestamp) 

    ## TODO check if client is on the "toServeList"

    delete data.signature
    content = req.path+JSON.stringify(data)
    verified = await secUtl.verify(sigHex, idHex, content)
    
    if !verified then throw new Error("Invalid Signature!")
    return

#endregion

############################################################
export authenticateRequest = (req) ->
    log "authenticateRequest"
    log req.path
    try switch req.path
        when "/getNodeId","/startSession" then await authenticateClient(req)
        when "/addClientToServe","/getClientsToServe","/removeClientToServe" then await authenticateMaster(req)
        else await authenticateSession(req)
    catch err 
        log  "Error on authenticateRequest! #{err.message}"
        throw new Error("Error on authenticateRequest! #{err.message}")
    return



export addClientToServe = (idHex) ->
    # toServeList[idHex] = true
    return


