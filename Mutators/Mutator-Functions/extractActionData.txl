function extractActionData
    replace [script_block]
        Statements [repeat openHAB_declaration_or_statement]

    construct _ [repeat openHAB_declaration_or_statement]
        Statements  [exportActionFunctionItemValue] [exportActionMethodItemValue]
                    [exportActionMethodItemDotValue]

    by
        Statements
end function

function exportActionFunctionItemValue
    replace * [statement]
        ReplacementAction [id]
        '( ReplacementItem [id], ReplacementValue [id] ')
    
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
        ReplacementItem '. ReplacementAction '( ReplacementValue ')
end function