function removeConditions2
    replace [script_block]
        %Statements [repeat openHAB_declaration_or_statement]

    'if '( Condition [condition] ')
        '{
            Block [block]
        '}
    
        %deconstruct Block
            %Statements [repeat declaration_or_statement]

        by
            logInfo("Front Door", "Locking.")
    

    %construct ModifiedStatements [repeat openHAB_declaration_or_statement]
    %    Statements [removeSingleLineWithBracesConditions] [removeSingleLineConditions]
    %                [removeMultiLineConditions]

    %by
    %    ModifiedStatements
end function

rule removeSingleLineWithBracesConditions
    replace [statement]
        'if '( Condition [condition] ')
            Block [block]
    by
        somestuff
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

