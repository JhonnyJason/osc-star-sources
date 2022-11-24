############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("servicefunctions")
#endregion

############################################################
import * as auth from "./authmodule.js"
import * as serviceKeys from "./servicekeysmodule.js"
import * as sessionAuth from "./sessionauthmodule.js"

############################################################
#region service Functions

############################################################
## Master Functions
export addClientToServe = (req) ->
    log "addClientToServe"
    { clientPublicKey } = req.body
    auth.addClientToServe(clientPublicKey)
    return

export getClientsToServe = (req) ->
    log "getClientsToServe"
    toServeList = auth.getClientsToServe()
    return {toServeList}

export removeClientToServe = (req) ->
    log "removeClientToServe"
    { clientPublicKey } = req.body
    auth.removeClientToServe(clientPublicKey)
    return


############################################################
## Client Functions
export getSignedNodeId = (req) ->
    log "getSignedNodeId"
    response = await serviceKeys.getSignedNodeId()
    return response

export startSession = (req) ->
    log "startSession"
    { publicKey } = req.body
    request = JSON.stringify(req.body)
    await sessionAuth.startSession(publicKey, request)
    return


############################################################
## Client Functions
export addChatSite = (req) ->
    log "addChatSite - not implemented yet!"
    return

export getAllChatSites = (req) ->
    log "getAllChatSites - not implemented yet!"
    ## TODO implement
    response = {
        chatSites: [
            "extensivlyon.coffee/the-ultimate-vision",
            "extensivlyin.coffee/strunfun",
            "extensivlyon.coffee/thingycreate"
        ]
    }
    return response

export removeChatSite = (req) ->
    log "removeChatSite - not implemented yet!"
    return

#endregion
