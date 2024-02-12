function identicalConditions2
    replace [script_block]
        Statements [repeat openHAB_declaration_or_statement]

    %%% Process each statement one by one:
    %%% Keep expression statements, remove if statements
    construct EmptyStatements [repeat openHAB_declaration_or_statement]
        % none
    construct ProcessedStatements [repeat openHAB_declaration_or_statement]
        EmptyStatements [ProcessStatement each Statements]

    by
        ProcessedStatements   
end function

function ProcessStatement Statement [openHAB_declaration_or_statement]
    replace [repeat openHAB_declaration_or_statement]
        Statements [repeat openHAB_declaration_or_statement]

    construct ModifiedStatement [openHAB_declaration_or_statement]
        Statement   [changeIfStatement]
                    [keepStatement]
    
    by
        Statements [. ModifiedStatement]
end function

function keepStatement
    replace [openHAB_declaration_or_statement]
        Statement [openHAB_declaration_or_statement]

    where not
        Statement [isIfStatement]

    by
        Statement
end function

function changeIfStatement
    replace [openHAB_declaration_or_statement]
        'if '( Condition [condition] ')
            Block [block]

    import ReplacementCondition [condition]

    by
        'if '( ReplacementCondition ')
            Block
end function

function isIfStatement
    match [openHAB_declaration_or_statement]
        IfStatement [if_statement]
end function
        






function removeConditions2
    replace [script_block]
        Statements [repeat openHAB_declaration_or_statement]

    %%% Process each statement one by one:
    %%% Keep expression statements, remove if statements
    construct EmptyStatements [repeat openHAB_declaration_or_statement]
        % none
    construct ProcessedStatements [repeat openHAB_declaration_or_statement]
        EmptyStatements [processStatements each Statements]

    by
        ProcessedStatements   
end function


function processStatements Statement [openHAB_declaration_or_statement]
    replace [repeat openHAB_declaration_or_statement]
        Statements [repeat openHAB_declaration_or_statement]

    %%% Change Statement to [repeat] type to match the input type of removeIfStatement function
    construct StatementCast [repeat openHAB_declaration_or_statement]
        Statement

    construct ProcessedStatement [repeat openHAB_declaration_or_statement]
        StatementCast [removeIfStatement]

    by
        Statements [. ProcessedStatement]
end function


rule removeIfStatement
    replace [repeat openHAB_declaration_or_statement]
        'if '( Condition [condition] ')
            Block [block]

    deconstruct Block
        '{ 
            DeclsOrStates [repeat declaration_or_statement]
        '}
            
    construct EmptyStatements [repeat openHAB_declaration_or_statement]
        % Empty
    construct ExtractedStatements [repeat openHAB_declaration_or_statement]
        EmptyStatements [extractStatements each DeclsOrStates]

    by
        ExtractedStatements
end rule

function extractStatements DeclOrState [declaration_or_statement]

    deconstruct DeclOrState
        Statement [statement]

    replace [repeat openHAB_declaration_or_statement]
        OHDeclOrStates [repeat openHAB_declaration_or_statement]

    construct NewStatement [openHAB_declaration_or_statement]
        Statement
    by
        OHDeclOrStates [. NewStatement]
end function