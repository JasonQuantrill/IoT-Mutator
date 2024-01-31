function removeConditions2
    replace [script_block]
        Statements [repeat openHAB_declaration_or_statement]

    construct ModifiedStatements [repeat openHAB_declaration_or_statement]
        Statements [removeSingleLineWithBracesConditions] [removeSingleLineConditions]
                    [removeMultiLineConditions]

    by
        ModifiedStatements
end function

rule removeSingleLineWithBracesConditions
    replace [statement]
        'if '( Condition [condition] ')
        '{
            Statement [statement]
        '}

    by
        Statement
end rule

rule removeSingleLineConditions
    replace [statement]
        'if '( Condition [condition] ')     
        Statement [statement]

    deconstruct Statement
    '{ InnerStatements [statement] '}

    by
        Statement
end rule

rule removeMultiLineConditions
    replace [statement]
        'if '( Condition [condition] ')
        Statement [statement]

        deconstruct Statement
            Block_Statement [block_statement]

        deconstruct Block_Statement
            Block [block]

        deconstruct Block
            '{
                Statements [repeat declaration_or_statement]
            '}

        

    by
        Statements
end rule

