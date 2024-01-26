function extractActionData
    replace [script_block]
        Statements [repeat openHAB_declaration_or_statement]

    construct _ [repeat openHAB_declaration_or_statement]
        Statements  [exportActionFunctionItemValue] [exportActionMethodItemValue]

    by
        Statements
end function

function exportActionFunctionItemValue
    replace * [statement]
        Action [id]
        '( ReplacementItem [id], ReplacementValue [id] ')

    export ReplacementItem
    export ReplacementValue

    by
        Action '( ReplacementItem, ReplacementValue )
end function

function exportActionMethodItemValue
    replace * [statement]
        ReplacementItem [id]
        '. Action [id] '( ReplacementValue [id] ')

    export ReplacementItem
    export ReplacementValue

    by
        ReplacementItem '. Action '( ReplacementValue ')
end function