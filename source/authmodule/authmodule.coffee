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
toServe = {}

############################################################
masterKeyId = ""


############################################################
export getMasterKeyId = -> masterKeyId

############################################################
export assertClientIsToBeServed = (idHex) ->
    if !toServe[idHex] then throw new Error("Client #{idHex} is not to be served!")
    return


############################################################
export addClientToServe = (idHex) ->
    # toServe[idHex] = true
    return

export removeClientToServe = (idHex) ->
    # delete toServe[idHex]
    return

export getClientsToServe = -> Object.keys(toServe)


