%%%%%%%%%%%%%%
% ACTION MAINS
%%%%
function processAction
    import Completed [boolean_literal]
    deconstruct Completed
        'false

    replace [openHAB_declaration_or_statement]
        Statement [openHAB_declaration_or_statement]
    
    construct ProcessedStatement [openHAB_declaration_or_statement]
        Statement [extractAction] [replaceAction]
    
    by ProcessedStatement
end function

function extractAction
    import Replacing [boolean_literal]
    deconstruct Replacing
        'false

    replace [openHAB_declaration_or_statement]
        Statement [openHAB_declaration_or_statement]

    construct _ [openHAB_declaration_or_statement]
        Statement [extractActionFunctionValue] [extractActionMethodValue]

    by
        Statement
end function

function replaceAction
    import Replacing [boolean_literal]
    deconstruct Replacing
        'true

    replace [openHAB_declaration_or_statement]
        Statement [openHAB_declaration_or_statement]

    construct ProcessedStatement [openHAB_declaration_or_statement]
        Statement   [replaceActionFunctionItemValue] [replaceActionFunctionItem]
                    [replaceActionMethodItemValue] [replaceActionMethodItem]

    by
        ProcessedStatement
end function



%%%%%%%%%%%%%%
% REPLACEMENT PATTERNS
%%%%

%% postUpdate(ITEM, VALUE)
function replaceActionFunctionItemValue
    replace [openHAB_declaration_or_statement]
        Action [id]
        '( Item [expression], Value [expression] ')

    % check to see if Action is an action that changes an Item
    where
        Action [= "postUpdate"] [= "sendCommand"]

    import ReplacementItem [id]
    import ReplacementValue [id]

    % check to see if replacement value has been assigned
    where not
        ReplacementValue [= "nothing"]

    construct FinalReplacementValue [id]
        ReplacementValue [oppositeAction] [leaveAction]

    export Completed [boolean_literal]
        'true

    by
        Action '( ReplacementItem, FinalReplacementValue ')
end function

%% postUpdate(ITEM, value)
function replaceActionFunctionItem
    replace [openHAB_declaration_or_statement]
        Action [id]
        '( Item [expression], Value [expression] ')

    % check to see if Action is an action that changes an Item
    where
        Action [= "postUpdate"] [= "sendCommand"]

    import ReplacementItem [id]
    import ReplacementValue [id]

    %%% Keep value the same if replacement value is not specified
    where
        ReplacementValue [= "nothing"]

    export Completed [boolean_literal]
        'true

    by
        Action '( ReplacementItem, Value ')
end function

%% ITEM.postUpdate(VALUE)
function replaceActionMethodItemValue
    replace [openHAB_declaration_or_statement]
        Item [id]
        '. Action [id] '( Value [expression] ')

    % check to see if Action is an action that changes an Item
    where
        Action [= "postUpdate"] [= "sendCommand"]

    import ReplacementItem [id]
    import ReplacementValue [id]

    where not
        ReplacementValue [= "nothing"]

    construct FinalReplacementValue [id]
        ReplacementValue [oppositeAction] [leaveAction]

    export Completed [boolean_literal]
        'true

    by
        ReplacementItem '. Action '( FinalReplacementValue ')
end function

%% ITEM.postUpdate(value)
function replaceActionMethodItem
    replace [openHAB_declaration_or_statement]
        Item [id]
        '. Action [id] '( Value [expression] ')

    % check to see if Action is an action that changes an Item
    where
        Action [= "postUpdate"] [= "sendCommand"]

    import ReplacementItem [id]
    import ReplacementValue [id]

    where
        ReplacementValue [= "nothing"]
    
    export Completed [boolean_literal]
        'true

    by
        ReplacementItem '. Action '( Value ')
end function


%%%%%%%%%%%%%%
% EXTRACTION PATTERNS
%%%%

function extractActionFunctionValue
    replace [openHAB_declaration_or_statement]
        ReplacementAction [id]
        '( ReplacementItem [id], ReplacementValue [id] ')

    where
        ReplacementAction [= "postUpdate"] [= "sendCommand"]
    where
        ReplacementValue [= "ON"] [= "OFF"] [= "OPEN"] [= "CLOSED"]
    
    export ReplacementAction
    export ReplacementItem
    export ReplacementValue
    
    export Completed [boolean_literal]
        'true

    by
        ReplacementAction '( ReplacementItem, ReplacementValue ')
end function

function extractActionMethodValue
    replace [openHAB_declaration_or_statement]
        ReplacementItem [id]
        '. ReplacementAction [id] '( ReplacementValue [id] ')

    where
        ReplacementAction [= "postUpdate"] [= "sendCommand"]
    where
        ReplacementValue [= "ON"] [= "OFF"] [= "OPEN"] [= "CLOSED"]

    export ReplacementAction
    export ReplacementItem
    export ReplacementValue

        
    export Completed [boolean_literal]
        'true

    by
        ReplacementItem '. ReplacementAction '( ReplacementValue ')
end function



%%%%%%%%%%%%%%
% REPLACEMENT OPPOSITE HELPERS
%%%%
function oppositeAction
    import Opposite [boolean_literal]
    deconstruct Opposite
        'true

    replace [id]
        Value [id]

    construct OppositeValue [id]
        Value   [onToOff] [offToOn]
                [openToClosed] [closedToOpen]
    by
        OppositeValue
end function

function leaveAction
    import Opposite [boolean_literal]
    deconstruct Opposite
        'false

    replace [id]
        Value [id]

    by
        Value
end function

function onToOff
    replace [id]
        Value [id]
    export Swapped [boolean_literal]
        'false
    where
        Value [= "ON"]
    export Swapped
        'true
    by
        OFF
end function

function offToOn
    replace [id]
        Value [id]
    where
        Value [= "OFF"]
    import Swapped [boolean_literal]
    deconstruct Swapped
        'false
    by
        ON
end function

function openToClosed
    replace [id]
        Value [id]
    export Swapped [boolean_literal]
        'false
    where
        Value [= "OPEN"]
    export Swapped
        'true
    by
        CLOSED
end function

function closedToOpen
    replace [id]
        Value [id]
    where
        Value [= "CLOSED"]
    import Swapped [boolean_literal]
    deconstruct Swapped
        'false
    by
        OPEN
end function