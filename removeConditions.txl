function removeConditions2
    replace [script_block]
        Statements [repeat openHAB_declaration_or_statement]

    construct ModifiedStatements [repeat openHAB_declaration_or_statement]
        Statements [something]

    by
        ModifiedStatements
end function


function keepStatements
    replace [repeat openHAB_declaration_or_statement]
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

    construct ProcessedStatement [repeat openHAB_declaration_or_statement]
        


    by
        Statements [. ProcessedStatement]
end function
    


rule something
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



rule removeSingleLineConditions
    replace [statement]
        'if '( Condition [condition] ')
        Statement [statement]

    deconstruct Statement
    '{ InnerStatements [statement] '}

    by
        Statement
end rule




% problem: replace [openHAB_declaration_or_statement] with [repeat declaration_or_statement]
% replace [statement] with [repeat statement]

%construct EmptyStates
%construct states [repeat openHAB_declaration_or_statement]
    %EmptyStates [convertToStates each [repeat delcaration or statement]]

%convertToStates DeclOrState [repeat delcaration or statement]

    %deconstrcut DeclsOrStates
        %statement [statement]

    %replace [repeat openHAB_declaration_or_statement]
        %decls [repeat openHAB_declaration_or_statement]
    %by
        %decls [. statement]