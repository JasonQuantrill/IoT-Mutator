%% Attempt to apply all of the different patterns
function modifyAction
    replace [script_block]
        Statements [repeat openHAB_declaration_or_statement]

    construct ModifiedStatements [repeat openHAB_declaration_or_statement]
        Statements [modifyActionFunctionItemValue] [modifyActionFunctionItem]
                    [modifyActionMethodItemValue] [modifyActionMethodItem]

    by
        ModifiedStatements
end function

%%%%%%
% Main patterns
%%%%%%

%% Changes the Item and Value for patterns such as
%% postUpdate(Item, Value)
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


%% Changes only the Item for patterns such as
%% postUpdate(Item, Value)
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


%% Changes the Item and Value for patterns such as
%% Item.postUpdate(Value)
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


%% Changes only the Item for patterns such as
%% Item.postUpdate(Value)
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


%%%%%%
% Modifying the action value
%%%%%%

%% Applying different patterns
function modifyActionOpposite
    replace [script_block]
        Statements [repeat openHAB_declaration_or_statement]

    construct ModifiedStatements [repeat openHAB_declaration_or_statement]
        Statements [modifyActionFunctionItemOppositeValue] [modifyActionMethodItemOppositeValue]

    by
        ModifiedStatements
end function


%% Change action value for patterns such as
%% postUpdate(Item,ON)
function modifyActionFunctionItemOppositeValue
    replace * [statement]
        Action [id]
        '( ItemB1 [expression], Value [expression] ')

    % check to see if Action is an action that changes an Item
    where
        Action [= "postUpdate"] [= "sendCommand"]

    import ReplacementItem [id]
    import ReplacementValue [id]

    where not
        ReplacementValue [= "nothing"]

    construct OppositeValue [id]
        ReplacementValue [getOpposite]

    by
        Action '( ReplacementItem, OppositeValue ')
end function


%% Change action value for patterns such as
%% Item.postUpdate(ON)
function modifyActionMethodItemOppositeValue
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

    construct OppositeValue [id]
        ReplacementValue [getOpposite]

    by
        ReplacementItem '. Action '( OppositeValue ')
end function


%% Get the opposite value of the action value
function getOpposite
    replace [id]
        Value [id]
    
    construct OppositeValue [id]
        Value   [onToOff] [offToOn]
                [openToClosed] [closedToOpen]
    by
        OppositeValue
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