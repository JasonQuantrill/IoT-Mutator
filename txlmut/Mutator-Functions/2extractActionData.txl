function extractActionData
    replace [script_block]
        Statements [repeat openHAB_declaration_or_statement]

    construct _ [repeat openHAB_declaration_or_statement]
        Statements  [exportActionFunctionItemValue] [exportActionMethodItemValue]
                    [exportActionMethodItemDotValue] [exportActionMethodItemDotValue]

    by
        Statements
end function

function exportActionFunctionItemValue
    replace * [statement]
        ReplacementAction [id]
        '( ReplacementItem [id] , ReplacementValue [id] ')
    
    export ReplacementAction
    export ReplacementItem
    export ReplacementValue

    by
        ReplacementAction '( ReplacementItem, ReplacementValue )
end function

function exportActionMethodItemValue
    replace * [statement]
        ReplacementItem [id]
        '. ReplacementAction [id] '( ReplacementValue [id] ')

    export ReplacementAction
    export ReplacementItem
    export ReplacementValue

    by
        ReplacementItem '. ReplacementAction '( ReplacementValue ')
end function

function exportActionMethodItemDotValue
    replace * [statement]
        ReplacementItem [id]
        '. ReplacementAction [id] '( ReplacementActionItem [id] '. ReplacementValue [id] ')

    export ReplacementAction
    export ReplacementItem
    export ReplacementValue

    by
        ReplacementItem '. ReplacementAction '( ReplacementActionItem '. ReplacementValue ')
end function

function exportActionFunctionItemDotValue
    replace * [statement]
        ReplacementAction [id]
        '( ReplacementItem [id], ReplacementActionItem [id] '. ReplacementValue [id] ')

    export ReplacementAction
    export ReplacementItem
    export ReplacementValue

    by
        ReplacementAction
        '( ReplacementItem, ReplacementActionItem '. ReplacementValue ')
end function





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function extractActionValueData
    replace [script_block]
        Statements [repeat openHAB_declaration_or_statement]

    %construct _ [repeat openHAB_declaration_or_statement]
        %Statements  [exportActionValueFunctionItemValue] [exportActionValueMethodItemValue]

    by
        Statements
end function

function extractActionFunctionValue
    replace [openHAB_declaration_or_statement]
        ReplacementAction [id]
        '( ReplacementItem [id], ReplacementValue [id] ')

    import Extracted [boolean_literal]
    deconstruct Extracted
        'false

    where
        ReplacementValue [= "ON"] [= "OFF"] [= "OPEN"] [= "CLOSED"]
    
    export ReplacementAction
    export ReplacementItem
    export ReplacementValue
    
    export Extracted
        'true

    by
        ReplacementAction '( ReplacementItem, ReplacementValue )
end function

function extractActionMethodValue
    replace [openHAB_declaration_or_statement]
        ReplacementItem [id]
        '. ReplacementAction [id] '( ReplacementValue [id] ')

    import Extracted [boolean_literal]
    deconstruct Extracted
        'false

    where
        ReplacementValue [= "ON"] [= "OFF"] [= "OPEN"] [= "CLOSED"]

    export ReplacementAction
    export ReplacementItem
    export ReplacementValue

        
    export Extracted
        'true

    by
        ReplacementItem '. ReplacementAction '( ReplacementValue ')
end function