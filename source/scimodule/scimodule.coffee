############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("scimodule")
#endregion


############################################################
#region modules from the Environment
import * as sciBase from "thingy-sci-ws-base"

import { onConnect } from "./wsimodule.js"
import * as authenticationHandlers from "./authenticationhandlers.js"
import * as authenticationRoutes from "./authenticationroutes.js"

#endregion

############################################################
export prepareAndExpose = ->
    log "scimodule.prepareAndExpose"
    authenticationHandlers.setService(serviceFunctions)
    authenticationRoutes.setAuthenticationFunction(authenticateRequest)


    allRoutes = Object.assign()
    sciBase.prepareAndExpose(null, allRoutes)
    sciBase.onWebsocketConnect("/", onConnect)
    WSHandle = sciBase.getWSHandle()
    return

############################################################
#region service Functions

############################################################
## Master Functions


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

############################################################
serviceFunctions =  {
    # Master Functions
    addClientToServe,
    getClientsToServe,
    removeClientToServe,

    # Client Functions
    getSignedNodeId,
    startSession
}