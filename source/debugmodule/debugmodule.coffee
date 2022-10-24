import { addModulesToDebug } from "thingy-debug"

############################################################
export modulesToDebug = {
    authenticationfunctions: true
    # blocksignaturesmodule: true
    # configmodule: true
    # scimodule: true
    servicefunctions: true
    # startupmodule: true
}
    
addModulesToDebug(modulesToDebug)