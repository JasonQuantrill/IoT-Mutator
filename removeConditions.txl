function removeConditions2
    replace [script_block]
        Statements [repeat openHAB_declaration_or_statement]

    construct ModifiedStatements [repeat openHAB_declaration_or_statement]
        Statements [removeConditionsWithBraces] [removeConditionsNoBraces]

    by
        ModifiedStatements
end function

rule removeConditionsWithBraces
    replace [statement]
        'if '( Condition [condition] ')
            '{ 
                Statements [repeat declaration_or_statement]
            '}
            Else [opt else_clause]

        deconstruct Statements
            ExtractedStatements [statement]
    by
        ExtractedStatements
end rule

rule removeConditionsNoBraces
    replace [statement]
        'if '( Condition [condition] ')     
            Statement [statement]
            Else [opt else_clause]
    by
        Statement
end rule

