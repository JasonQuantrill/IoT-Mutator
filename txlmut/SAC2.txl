% TXL OpenHAB Rules Grammar
include "Dependencies/openhab.grm"
include "Mutator-Functions/2extractActionData.txl"
include "Mutator-Functions/modifyAction.txl"
%include "Mutator-Functions/modifyConditions.txl"

function main
    replace [program]
        P [program]
    construct NewP [program]
        P [createStrongActionContradiction]
    by
        NewP
end function


function createStrongActionContradiction
    replace [program]
        Package [opt package_header]
        Import [repeat import_declaration]
        Declares [repeat variable_declaration]
        Rules [repeat OpenHAB_rule]

    construct ModifiedRules  [repeat OpenHAB_rule]
        Rules   [modifyActionWithActionData]
                [forceIdenticalTriggers]
                % [removeConditions]
    
    by
        Package
        Import
        Declares
        ModifiedRules
end function


function modifyActionWithActionData
    replace [repeat OpenHAB_rule]
        Rules [repeat OpenHAB_rule]
    
    deconstruct Rules
        RuleA [OpenHAB_rule] RestA [repeat OpenHAB_rule]
    deconstruct RestA
        RuleB [OpenHAB_rule] RestB [repeat OpenHAB_rule]

    deconstruct RuleA
        'rule NameA [rule_id]
        'when
            TriggerA [trigger_condition]
            MoreTCA [repeat moreTC]
        'then 
            ScriptA [script_block]
        'end

    deconstruct RuleB
        'rule NameB [rule_id]
        'when
            TriggerB [trigger_condition]
            MoreTCB [repeat moreTC]
        'then 
            ScriptB [script_block]
        'end

    construct ModifiedScriptA [script_block]
        ScriptA [extractActionRemoveCondition]

    construct ModifiedScriptB [script_block]
        ScriptB [modifyActionOpposite]

    by
        'rule NameA
        'when
            TriggerA
            MoreTCA
        'then 
            ModifiedScriptA
        'end

        'rule NameB
        'when
            TriggerB
            MoreTCB
        'then 
            ModifiedScriptB
        'end
        RestB
end function

function forceIdenticalTriggers
    replace [repeat OpenHAB_rule]
        Rules [repeat OpenHAB_rule]
    
    deconstruct Rules
        RuleA [OpenHAB_rule] RestA [repeat OpenHAB_rule]
    deconstruct RestA
        RuleB [OpenHAB_rule] RestB [repeat OpenHAB_rule]

    deconstruct RuleA
        'rule NameA [rule_id]
        'when
            TriggerA [trigger_condition]
            MoreTCA [repeat moreTC]
        'then 
            ScriptA [script_block]
        'end

    deconstruct RuleB
        'rule NameB [rule_id]
        'when
            TriggerB [trigger_condition]
            MoreTCB [repeat moreTC]
        'then 
            ScriptB [script_block]
        'end
    
    by
        'rule NameA
        'when
            TriggerA
            MoreTCA
        'then 
            ScriptA
        'end

        'rule NameB
        'when
            TriggerA
            MoreTCA
        'then 
            ScriptB
        'end
        RestB
end function

function extractActionRemoveCondition
    replace [script_block]
        Statements [repeat openHAB_declaration_or_statement]

    export Extracted [boolean_literal]
        'false

    %%% This part of the program works as follows:
    % Several passes are made, going line-by-line over the rule, searching for action-value statements
    % Each pass explores one layer more deeply into 'if' statements
    % The first pass does not explore any if-statements, treating the entire if-block construct as 1 statement
    % As each line is considered, it is then added to the list of FirstPassStatements in the rule
    % By the end of the pass, all of the original statements have been added
    % When an action-value statement is found, the action data is extracted, and the 'Extracted' flag is set
    % When the flag is set, then goal is fulfilled, and the remaining statements are added to the list
    % Subsequent passes are ignored and the completed list is passed along down until it is eventually returned
    % If no action-value statement is found, the completed list is erased, and the process starts over.
    % The second pass similarly considers each statement one by one, adding them to the SecondPassStatements list
    % When a statement is an if-statement, it is explored, searching for an action-value statement
    % If no action-value statement is found in the if-block, the if-statement is added unchanged to SecondPassStatements
    % If one is found, the action data is extracted and the flag is set
    % The if-conditional is removed, and all of its statements are extracted and added to the SecondPassStatements.
    % If it is part of an if-ifelse-else construct, the branch where the action was found is kept, while the other branches are erased.
    % The pass then finishes itself, subsequent passes are ignored, and SecondPassStatements is returned
    % If an action-value is not found at this depth, nested-ifs are then explored, and so on
    %%% The algorithm does layer-by-layer searching to prioritize finding the shallowest solution, minimizing the diff-size of the mutation

    construct EmptyStatements [repeat openHAB_declaration_or_statement]
        % none
    construct FirstPassStatements [repeat openHAB_declaration_or_statement]
        EmptyStatements [processActionStatement each Statements]

    construct PrepareForSecondPass [repeat openHAB_declaration_or_statement]
        FirstPassStatements [actionFound] [actionNotFoundYet]

    construct SecondPassStatements [repeat openHAB_declaration_or_statement]
        PrepareForSecondPass [processIfStatement each Statements]
  
    by
        SecondPassStatements   
end function

function actionFound
    import Extracted [boolean_literal]
        deconstruct Extracted
            'true

    replace [repeat openHAB_declaration_or_statement]
        Statements [repeat openHAB_declaration_or_statement]
    by
        Statements
end function

function actionNotFoundYet
    import Extracted [boolean_literal]
        deconstruct Extracted
            'false

    replace [repeat openHAB_declaration_or_statement]
        Statements [repeat openHAB_declaration_or_statement]
    construct EmptyStatements [repeat openHAB_declaration_or_statement]
        % none
    by
        EmptyStatements
end function
    
    
function processActionStatement Statement [openHAB_declaration_or_statement]
    replace [repeat openHAB_declaration_or_statement]
        Statements [repeat openHAB_declaration_or_statement]

    %%% this function looks at each statement
    %%% if the statement is an appropriate action and the 'extracted' flag is unset:
    %%% it extracts the data and sets the 'extracted' flag
    %%% then it adds each statement to the list
    construct ProcessedStatement [openHAB_declaration_or_statement]
        Statement   [extractActionFunctionValue] [extractActionMethodValue]
                    [keepStatement]
    
    by
        Statements [. ProcessedStatement]
end function



function processIfStatement Statement [openHAB_declaration_or_statement]
    replace [repeat openHAB_declaration_or_statement]
        Statements [repeat openHAB_declaration_or_statement]

    %%% Change Statement to [repeat] type to match the input type of removeIfStatement function
    construct StatementCast [repeat openHAB_declaration_or_statement]
        Statement

    %%% this function looks at each statement
    %%% if the statement is an if statement
    construct ProcessedStatement [repeat openHAB_declaration_or_statement]
        StatementCast   [singleLineIf] [multiLineIf]
                        [keepStatement]
                    
    
    by
        Statements [. ProcessedStatement]
end function


function multiLineIf
    %%% Skip processing if statements if extraction already complete
    import Extracted [boolean_literal]
    deconstruct Extracted
        'false

    replace [repeat openHAB_declaration_or_statement]
        'if '( Condition [condition] ')
            StatementsBlock [statement]

    deconstruct StatementsBlock
        '{ 
            Statements [repeat declaration_or_statement]
        '}
    
    construct EmptyStatements [repeat openHAB_declaration_or_statement]
        % Empty
    construct ProcessedIfBlockStatements [repeat openHAB_declaration_or_statement]
        EmptyStatements [ProcessIfBlockStatements each Statements]

    construct ProcessedIfStatement [repeat openHAB_declaration_or_statement]
        ProcessedIfBlockStatements [keepMultiIfAction] [keepMultiIfNotAction Condition]

    by
        ProcessedIfStatement
end function

function ProcessIfBlockStatements Statement [declaration_or_statement]
    replace [repeat openHAB_declaration_or_statement]
        Statements [repeat openHAB_declaration_or_statement]

    construct StatementCast [openHAB_declaration_or_statement]
        Statement

    %construct OHDeclOrState [openHAB_declaration_or_statement]
        %DeclOrState
        

    construct ProcessedStatement [openHAB_declaration_or_statement]
        StatementCast   [extractActionFunctionValue] [extractActionMethodValue]
                        [keepStatement]
    by
        Statements [. ProcessedStatement]
end function

function keepMultiIfNotAction Condition [condition]
    import Extracted [boolean_literal]
    deconstruct Extracted
        'false

    replace [repeat openHAB_declaration_or_statement]
        Statements [repeat openHAB_declaration_or_statement]
    
    construct emptyDOS [repeat declaration_or_statement]
        % empty
    construct DOSCast [repeat declaration_or_statement]
        emptyDOS [castToDOS each Statements]
        
    construct OriginalIfStatement [repeat openHAB_declaration_or_statement]
        'if '( Condition ') '{
            DOSCast
            '}
    by
        OriginalIfStatement
end function

function keepMultiIfAction
    import Extracted [boolean_literal]
    deconstruct Extracted
        'true

    replace [repeat openHAB_declaration_or_statement]
        Statement [repeat openHAB_declaration_or_statement]

    by
        Statement
end function

function castToDOS Statement [openHAB_declaration_or_statement]
    replace [repeat declaration_or_statement]
        DOS [repeat declaration_or_statement]
    deconstruct Statement
        DecOrState [declaration_or_statement]
    by
        DOS [. DecOrState]
end function


function singleLineIf
    %%% Skip processing if statements if extraction already complete
    import Extracted [boolean_literal]
    deconstruct Extracted
        'false

    replace [openHAB_declaration_or_statement]
        'if '( Condition [condition] ')
            Statement [statement]

    where not
        Statement [isBlock]
        
    construct StatementCast [openHAB_declaration_or_statement]
        Statement

    construct ProcessedStatement [openHAB_declaration_or_statement]
        StatementCast [extractActionFunctionValue] [extractActionMethodValue]
                        [keepSingleIfAction] [keepSingleIfNotAction Condition]
    by
        ProcessedStatement
end function

function keepSingleIfNotAction Condition [condition]
    import Extracted [boolean_literal]
        deconstruct Extracted
            'false
    
    replace [openHAB_declaration_or_statement]
        Statement [openHAB_declaration_or_statement]

    deconstruct Statement 
        StatementCast [statement]
    construct OriginalIfStatement [openHAB_declaration_or_statement]
        'if '( Condition ')
            StatementCast
    by
        OriginalIfStatement
end function

function keepSingleIfAction
    import Extracted [boolean_literal]
        deconstruct Extracted
            'true

    replace [openHAB_declaration_or_statement]
        Statement [openHAB_declaration_or_statement]
    
    by
        Statement
end function


function keepStatement
    replace [openHAB_declaration_or_statement]
        Statement [openHAB_declaration_or_statement]
    by
        Statement
end function

function isBlock
    match [statement]
        Statement [statement]
    deconstruct Statement
        '{ 
            DeclsOrStates [repeat declaration_or_statement]
        '}
end function
