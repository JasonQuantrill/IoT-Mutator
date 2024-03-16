%%% Need to define following global variables in main
%   construct ReplacementItem [id]
%       nothing
%   export ReplacementItem
%   construct ReplacementValue [id]
%       nothing
%   export ReplacementValue


function extractTriggerData
    replace [trigger_condition]
        Trigger [trigger_condition]

    %%% Multiple functions to try to match different trigger patterns. Only 1 will succeed.
    %%% Different patterns include "received command", "post update ON", "changed to ON", etc
    %%% Export function extracts the trigger data as global variables so they can be used in the replacement
    construct _ [trigger_condition]
        Trigger [exportTriggerRCItem] [exportTriggerRUItem] [exportTriggerCItem]
                [exportTriggerRCItemValue] [exportTriggerRUItemValue] [exportTriggerCItemValue]

    by  
        Trigger
end function

function exportTriggerRCItem
    replace [trigger_condition]
        'Item ReplacementItem [id]
        'received 'command

    export ReplacementItem

    by
        'Item ReplacementItem
        'received 'command
end function

function exportTriggerRCItemValue
    replace [trigger_condition]
        'Item ReplacementItem [id]
        'received 'command
        Command [opt command]

    deconstruct Command
        ReplacementValue [id]

    export ReplacementItem
    export ReplacementValue

    by
        'Item ReplacementItem
        'received 'command
        Command
end function

function exportTriggerRUItem
    replace [trigger_condition]
        'Item ReplacementItem [id]
        'received 'update

    export ReplacementItem
    
    by
        'Item ReplacementItem
        'received 'update
end function

function exportTriggerRUItemValue
    replace [trigger_condition]
        'Item ReplacementItem [id]
        'received 'update
        State [opt state]

     deconstruct State
        ReplacementValue [id]

    export ReplacementItem
    export ReplacementValue
    
    by
        'Item ReplacementItem
        'received 'update
        State
end function

function exportTriggerCItem
    replace [trigger_condition]
        'Item ReplacementItem [id]
        'changed

    export ReplacementItem
    
    by
        'Item ReplacementItem
        'changed
end function

function exportTriggerCItemValue
    replace [trigger_condition]
        'Item ReplacementItem [id]
        'changed
        TriggerFrom [opt from_range]
        TriggerTo [opt to_range]

    deconstruct TriggerTo
        'to ReplacementValue [id]

    export ReplacementItem
    export ReplacementValue
    
    by
        'Item ReplacementItem
        'changed
        TriggerFrom
        TriggerTo
end function