############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("authenticationfunctions")
#endregion

############################################################
import * as secUtl from "secret-manager-crypto-utils"
import * as timestampVerifier from "./validatabletimestampmodule.js"
import * as blocker from "key-block"
import * as auth from "./authmodule.js"
import * as session from "./sessionauthmodule.js"

############################################################
export masterAuthentication = (route, args) ->
    log "masterAuthentication"
    sigHex = args.signature
    timestamp = args.timestamp

    if !timestamp then throw new Error("No Timestamp!") 
    if !sigHex then throw new Error("No Signature!")

    idHex = auth.getMasterKeyId()

    olog args
    # olog sigHex
    # olog timestamp

    # assert that the signature has not been used yet
    blocker.blockOrThrow(sigHex)
    # will throw if timestamp is not valid 
    timestampVerifier.assertValidity(timestamp) 

    delete args.signature
    content = route+JSON.stringify(args)
    verified = await secUtl.verify(sigHex, idHex, content)
    args.signature = sigHex

    if !verified then throw new Error("Invalid Signature!")
    return
    
export clientAuthentication = (route, args) ->
    log "authenticateClient"
    idHex = args.publicKey
    sigHex = args.signature
    timestamp = args.timestamp

    if !timestamp then throw new Error("No Timestamp!") 
    if !sigHex then throw new Error("No Signature!")
    if !idHex then throw new Error("No PublicKey!")

    olog args
    # olog idHex
    # olog sigHex
    # olog timestamp

    # assert that the signature has not been used yet
    blocker.blockOrThrow(sigHex)
    # will throw if timestamp is not valid 
    timestampVerifier.assertValidity(timestamp) 
    # assert client is to be served
    auth.assertClientIsToBeServed(idHex)

    delete args.signature
    content = route+JSON.stringify(args)
    verified = await secUtl.verify(sigHex, idHex, content)
    args.signature = sigHex

    if !verified then throw new Error("Invalid Signature!")
    return

export sessionAuthentication = (route, args) ->
    authCode = args.authCode

    if !authCode then throw new Error("No AuthCode!")
    
    olog args
    requestString = JSON.stringify(args)
    args.session = session.getOrThrow(authCode)

    # content = route+JSON.stringify(args)
    session.generateNextAuthCode(args.session, requestString)
    return
