function removeConditions2
    replace [script_block]
        Statements [repeat openHAB_declaration_or_statement]

    construct ModifiedStatements [repeat openHAB_declaration_or_statement]
        Statements [removeSingleLineConditions]

    by
        ModifiedStatements
end function

function removeSingleLineConditions
    replace * [statement]
        'if '( Condition [condition] ')     
        Statement [statement]

    by
        Statement
end function

function removeMultiLineConditions
    replace * [statement]
        'if '( Condition [condition] ')     
        Statement [statement]
    Else [opt else_clause]

    by
        Action '( ReplacementItem, ReplacementValue ')
end function