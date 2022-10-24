############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("servicefunctions")
#endregion

############################################################
import *  as auth from "./authmodule.js"
import *  as serviceKeys from "./servicekeysmodule.js"

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
    log "getSignedNodeId - not implemented yet!"
    ## TODO implement
    response = {
        serverNodeId: "deadbeafdeadbeaddeadbeafdeadbeaddeadbeafdeadbeaddeadbeafdeadbead"
        timestamp: 1
        signature: "deadbeafdeadbeaddeadbeafdeadbeaddeadbeafdeadbeaddeadbeafdeadbeaddeadbeafdeadbeaddeadbeafdeadbeaddeadbeafdeadbeaddeadbeafdeadbead" 
    }
    return response

export startSession = (req) ->
    log "startSession - not implemented yet!"
    return

#endregion
