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

    import ReplacementItem [id]
    import ReplacementValue [id]

    where not
        ReplacementValue [= "nothing"]

    by
        Action '( ReplacementItem, ReplacementValue ')
end function

function modifyActionFunctionItem
    replace * [statement]
        Action [id]
        '( ItemB1 [expression], Value [expression] ')

    import ReplacementItem [id]
    import ReplacementValue [id]

    where
        ReplacementValue [= "nothing"]

    by
        Action '( ReplacementItem, Value ')
end function

function modifyActionMethodItemValue
    replace * [statement]
        Item [id]
        '. Action [id] '( Value [expression] ')

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

    import ReplacementItem [id]
    import ReplacementValue [id]

    where
        ReplacementValue [= "nothing"]

    by
        ReplacementItem '. Action '( Value ')
end function