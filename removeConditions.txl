function removeConditions2
    replace [script_block]
        Statements [repeat openHAB_declaration_or_statement]

    % Construct an empty statement list.
    % Apply several filters to the original statements list
    % If they are expression statements, they get added to the list via [. ListItem]
    % If it is an if statement, its inner statements get added
    
    

    construct ModifiedStatements [repeat openHAB_declaration_or_statement]
        Statements [removeSingleLineWithBracesConditions] [removeSingleLineConditions]
                    [removeMultiLineConditions]

    by
        ModifiedStatements
end function

rule removeSingleLineWithBracesConditions
    replace [repeat openHAB_declaration_or_statement]
        'if '( Condition [condition] ')
            Block [block]

        deconstruct Block
            '{ 
                Statements [repeat declaration_or_statement]
            '}
            

    construct EmptyStatements [repeat openHAB_declaration_or_statement]
        % Empty
    construct ExtractedStatements [repeat openHAB_declaration_or_statement]
        EmptyStatements [extractStatements each Statements]

    by
        ExtractedStatements
end rule

function extractStatements Statement [repeat declaration_or_statement]

    deconstruct Statement
        


rule removeSingleLineConditions
    replace [statement]
        'if '( Condition [condition] ')
        Statement [statement]

    deconstruct Statement
    '{ InnerStatements [statement] '}

    by
        Statement
end rule

