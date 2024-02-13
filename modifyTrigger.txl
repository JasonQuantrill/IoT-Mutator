function modifyCompatibleTrigger
    replace [trigger_condition]
        Trigger [trigger_condition]

    %%% If these all fail, it means the triggers depend on different Items, and therefore are already compatible
    construct ModifiedTrigger [trigger_condition]
        Trigger [modifyCompatibleTriggerRC] [modifyCompatibleTriggerRU]
                [passTrigger]

    by
        ModifiedTrigger
end function


function modifyCompatibleTriggerRC    
    replace [trigger_condition]
        'Item ItemId [id]
        'received 'command
        Command [opt command]

    %%% If trigger doesn't specify a value, triggers are compatible, function will exit
    deconstruct Command
        Value [id]

    import ReplacementItem [id]
    import ReplacementValue [id]

    %%% Are the triggers acting on the same item?
    where
        ItemId [= ReplacementItem]
    %%% If first trigger doesn't specify a value, triggers are compatible
    where not
        ReplacementValue [= "nothing"]

    by
        'Item ReplacementItem
        'received 'command
        ReplacementValue
end function


function modifyCompatibleTriggerRU
    replace [trigger_condition]
        'Item ItemId [id]
        'received 'update
        State [opt state]

    %%% If trigger doesn't specify a value, triggers are compatible, function will exit
    deconstruct State
        Value [id]
    
    import ReplacementItem [id]
    import ReplacementValue [id]

    %%% Are the triggers acting on the same item?
    where
        ItemId [= ReplacementItem]
    %%% If first trigger doesn't specify a value, triggers are compatible
    where not
        ReplacementValue [= "nothing"]

    by
        'Item ReplacementItem
        'received 'update
        ReplacementValue
end function

function modifyCompatibleTriggerC
    replace [trigger_condition]
        'Item ItemId [id]
        'changed
        TriggerFrom [opt from_range]
        TriggerTo [opt to_range]

    %%% Leave out TriggerFrom in replacement. Then:
    %%% If trigger doesn't specify ToValue, triggers are compatible, function will exit
    deconstruct TriggerTo
        'to Value [id]
    
    import ReplacementItem [id]
    import ReplacementValue [id]

    %%% Are the triggers acting on the same item?
    where
        ItemId [= ReplacementItem]
    %%% If first trigger doesn't specify a value, triggers are compatible
    where not
        ReplacementValue [= "nothing"]

    by
        'Item ReplacementItem
        'changed
        'to ReplacementValue
end function



function passTrigger

    %%% Passing function to pass original trigger in case no other patterns match
    replace [trigger_condition]
        Trigger  [trigger_condition]
    by
        Trigger
end function


