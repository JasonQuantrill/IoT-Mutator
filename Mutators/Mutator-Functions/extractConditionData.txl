function extractConditionData
    replace [script_block]
        Statements [repeat openHAB_declaration_or_statement]

    construct _ [repeat openHAB_declaration_or_statement]
        Statements [exportCondition each Statements]

    by
        Statements
end function

function exportCondition Statement [openHAB_declaration_or_statement]
    replace [repeat openHAB_declaration_or_statement]
        Statements [repeat openHAB_declaration_or_statement]

        deconstruct Statement
            'if '( ReplacementCondition [condition] ')
                Block [block]

    export ReplacementCondition
    
    by
        Statements
end function