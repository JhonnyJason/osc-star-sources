############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("wsimodule")
#endregion


############################################################
import { validate as validateUUID } from 'uuid'
import { getWSHandle } from "thingy-sci-ws-base"


############################################################
clientIdCount = 0

clientIdtoUUID = {}
uuidToConnection = {}

############################################################
class SocketConnection
    constructor: (@socket, @clientId) ->
        # preseve that "this" is this class
        self = this
        @socket.onmessage = (evnt) -> self.onMessage(evnt)
        @socket.onclose = (evnt) -> self.onDisconnect(evnt)
        log "#{@clientId} connected!"
        @uuid = "none"

    onMessage: (evnt) ->
        log "onMessage"
        try
            message = evnt.data
            log "#{message}"
            
            commandEnd = message.indexOf(" ")
            if commandEnd < 0 then command = message
            else
                command = message.substring(0, commandEnd)
                postCommand = message.substring(commandEnd).trim()

            switch command
                when "setuuid" then @setUUID(postCommand)
                when "to" then messageTo(postCommand)
                when "getalluuids" then @socket.send("alluids #{Object.keys(uuidToConnection)}")
                when "sdp" then forwardSDPTo(postCommand)
                else throw new Error("unknown command: #{command}")

        catch err then log err
        return

    onDisconnect: (evnt) ->
        log "onDisconnect: #{@clientId}"
        try
            delete clientIdtoUUID[@clientId]
            delete uuidToConnection[@uuid]
            sendToAll("alluids #{Object.keys(uuidToConnection)}")

        catch err then log err
        return

    setUUID: (uuid) ->
        throw new Error("Invalid UUID") unless validateUUID(uuid)
        throw new Error("UUID already taken!") if uuidToConnection[uuid]?
        if @uuid != "none" then delete uuidToConnection[@uuid]

        @uuid = uuid
        clientIdtoUUID[@clientId] = uuid
        uuidToConnection[uuid] = this

        sendToAll("alluids #{Object.keys(uuidToConnection)}")
        return
    
    sendMessage: (message) -> @socket.send(message)

############################################################
forwardSDPTo = (content) ->
    uuidEnd = content.indexOf(" ")
    uuid = content.substring(0, uuidEnd)
    sdpString = content.substring(uuidEnd).trim()
    message = "sdp #{sdpString}"
    if !validateUUID(uuid) then throw new Error("invalid UUID: " + uuid)
    uuidToConnection[uuid].sendMessage(message)
    return
    
messageTo = (content) ->
    log "messageTo"
    keyEnd = content.indexOf(" ")
    key = content.substring(0, keyEnd)
    message = content.substring(keyEnd).trim()
    if validateUUID(key) then sendToUUID(key, "chat #{message}")
    else if key == "all" then sendToAll("chat #{message}")
    else throw new Error("invalid key for messageTo: #{key}")
    return

sendToUUID = (uuid, message) ->
    uuidToConnection[uuid].sendMessage(message)
    return

sendToAll = (message) ->
    for uuid,connection of uuidToConnection
        connection.sendMessage(message)
    return

############################################################
export onConnect = (socket, req) ->
    conn = new SocketConnection(socket, "#{clientIdCount}")
    clientIdCount++
    return

export mountWSFunctions = (routes) ->
    log "mountWSFunctions"
    ## TODO implement
    return