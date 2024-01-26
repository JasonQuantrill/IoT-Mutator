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
        'Item TriggerItem [id]
        'received 'command

    export TriggerItem

    by
        'Item TriggerItem
        'received 'command
end function

function exportTriggerRCItemValue
    replace [trigger_condition]
        'Item TriggerItem [id]
        'received 'command
        TriggerTo [opt command]

    deconstruct TriggerTo
        TriggerToValue [id]

    export TriggerItem
    export TriggerToValue

    by
        'Item TriggerItem
        'received 'command
        TriggerTo
end function

function exportTriggerRUItem
    replace [trigger_condition]
        'Item TriggerItem [id]
        'received 'update

    export TriggerItem
    
    by
        'Item TriggerItem
        'received 'update
end function

function exportTriggerRUItemValue
    replace [trigger_condition]
        'Item TriggerItem [id]
        'received 'update
        TriggerTo [opt state]

     deconstruct TriggerTo
        TriggerToValue [id]

    export TriggerItem
    export TriggerToValue
    
    by
        'Item TriggerItem
        'received 'update
        TriggerTo
end function

function exportTriggerCItem
    replace [trigger_condition]
        'Item TriggerItem [id]
        'changed

    export TriggerItem
    
    by
        'Item TriggerItem
        'changed
end function

function exportTriggerCItemValue
    replace [trigger_condition]
        'Item TriggerItem [id]
        'changed
        TriggerFrom [opt from_range]
        TriggerTo [opt to_range]

    deconstruct TriggerTo
        'to TriggerToValue [id]

    export TriggerItem
    export TriggerToValue
    
    by
        'Item TriggerItem
        'changed
        TriggerFrom
        TriggerTo
end function