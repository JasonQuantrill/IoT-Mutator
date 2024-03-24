include "Dependencies/openhab.grm"

function main

    %%% Defining global variables for extractActionData
    %%% Construct and export with "nothing" id
    construct ReplacementItem [id]
        nothing
    export ReplacementItem
    construct ReplacementValue [id]
        nothing
    export ReplacementValue
    construct ReplacementAction [id]
        nothing
    export ReplacementAction

    replace [program] 
        P [program]
    construct NewP [program]
        P %[createStrongTriggerCascade]
    by
        NewP
end function