function modifyAction
    replace [script_block]
        Statements [repeat openHAB_declaration_or_statement]

    construct ModifiedStatements [repeat openHAB_declaration_or_statement]
        Statements [modifyActionFunctionItemValue] [modifyActionFunctionItem]
                    [modifyActionMethodItemValue] [modifyActionMethodItem]

    by
        ModifiedStatements
end function

function modifyActionFunctionItemValue
    replace * [statement]
        Action [id]
        '( ItemB1 [expression], Value [expression] ')

    % check to see if Action is an action that changes an Item
    where
        Action [= "postUpdate"] [= "sendCommand"]

    import ReplacementItem [id]
    import ReplacementValue [id]

    % check to see if replacement value has been assigned
    where not
        ReplacementValue [= "nothing"]

    by
        Action '( ReplacementItem, ReplacementValue ')
end function

function modifyActionFunctionItem
    replace * [statement]
        Action [id]
        '( ItemB1 [expression], Value [expression] ')

    % check to see if Action is an action that changes an Item
    where
        Action [= "postUpdate"] [= "sendCommand"]

    import ReplacementItem [id]
    import ReplacementValue [id]

    %%% Keep value the same if replacement value is not specified
    where
        ReplacementValue [= "nothing"]

    by
        Action '( ReplacementItem, Value ')
end function

function modifyActionMethodItemValue
    replace * [statement]
        Item [id]
        '. Action [id] '( Value [expression] ')

    % check to see if Action is an action that changes an Item
    where
        Action [= "postUpdate"] [= "sendCommand"]

    import ReplacementItem [id]
    import ReplacementValue [id]

    where not
        ReplacementValue [= "nothing"]

    by
        ReplacementItem '. Action '( ReplacementValue ')
end function

function modifyActionMethodItem
    replace * [statement]
        Item [id]
        '. Action [id] '( Value [expression] ')

    % check to see if Action is an action that changes an Item
    where
        Action [= "postUpdate"] [= "sendCommand"]

    import ReplacementItem [id]
    import ReplacementValue [id]

    where
        ReplacementValue [= "nothing"]

    by
        ReplacementItem '. Action '( Value ')
end function




function modifyActionOpposite
    replace [script_block]
        Statements [repeat openHAB_declaration_or_statement]

    construct ModifiedStatements [repeat openHAB_declaration_or_statement]
        Statements [modifyActionFunctionItemOppositeValue] [modifyActionMethodItemOppositeValue]

    by
        ModifiedStatements
end function


function modifyActionFunctionItemOppositeValue
    replace * [statement]
        Action [id]
        '( ItemB1 [expression], Value [expression] ')

    import ReplacementItem [id]
    import ReplacementValue [id]

    where not
        ReplacementValue [= "nothing"]

    construct OppositeValue [id]
        ReplacementValue [getOpposite]

    by
        Action '( ReplacementItem, OppositeValue ')
end function


function modifyActionMethodItemOppositeValue
    replace * [statement]
        Item [id]
        '. Action [id] '( Value [expression] ')

    import ReplacementItem [id]
    import ReplacementValue [id]

    where not
        ReplacementValue [= "nothing"]

    construct OppositeValue [id]
        ReplacementValue [getOpposite]

    by
        ReplacementItem '. Action '( OppositeValue ')
end function



function getOpposite
    replace [id]
        Value [id]
    
    construct OppositeValue [id]
        Value   [onToOff] %[OffToOn]
                %[openToClosed] [ClosedToOpen]
    by
        OppositeValue
end function

function onToOff
    replace [id]
        Value [id]
    where
        Value [= "ON"]
    by
        OFF
end function