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




%%%%%%%%%%%%%%
% PASS MAIN
%%%%
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

    
    construct PrepareForFirstPass [repeat openHAB_declaration_or_statement]
        % empty
    %construct FirstPassStatements [repeat openHAB_declaration_or_statement]
    %    PrepareForFirstPass [processActionStatement each Statements]

    %construct PrepareForSecondPass [repeat openHAB_declaration_or_statement]
    %    FirstPassStatements [actionFound] [actionNotFoundYet]

    %construct SecondPassStatements [repeat openHAB_declaration_or_statement]
    %    PrepareForSecondPass [processIfStatement each Statements]

    %construct PrepareForThirdPass [repeat openHAB_declaration_or_statement]
        %SecondPassStatements [actionFound] [actionNotFoundYet]

    construct ThirdPassStatements [repeat openHAB_declaration_or_statement]
        %PrepareForThirdPass [processNestedIfStatement each Statements]
        PrepareForFirstPass [processNestedIfStatement each Statements]
  
    by
        ThirdPassStatements   
end function



%%%%%%%%%%%%%%
% PASS HELPERS
%%%%
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

function actionFoundInIf
    import Extracted [boolean_literal]
        deconstruct Extracted
            'true

    replace [repeat declaration_or_statement]
        ElseStatements [repeat declaration_or_statement]
    construct EmptyElseStatements [repeat declaration_or_statement]
        % empty
    by EmptyElseStatements
end function

function actionNotFoundInIf
    import Extracted [boolean_literal]
        deconstruct Extracted
            'false

    replace [repeat declaration_or_statement]
        ElseStatements [repeat declaration_or_statement]
    
    by ElseStatements
end function
    
%%%%%%%%%%%%%%
% PROCESSING MAINS
%%%%
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
        StatementCast   [singleLineIf] [multiLineIf] [ifElse]
                        [keepStatement]
                    
    by
        Statements [. ProcessedStatement]
end function

function processNestedIfStatement Statement [openHAB_declaration_or_statement]
    replace [repeat openHAB_declaration_or_statement]
        Statements [repeat openHAB_declaration_or_statement]

    construct StatementCast [repeat openHAB_declaration_or_statement]
        Statement
  
    construct ProcessedStatement [repeat openHAB_declaration_or_statement]
        StatementCast   [singleLineNest] [multiLineNest] [ifElseNest]
                        [keepStatement]
    by
        Statements [. ProcessedStatement]
end function


%%%%%%%%%%%%%%
% IF ELSE MAINS
%%%%
function singleLineIf
    %%% Skip processing if statements if extraction already complete
    import Extracted [boolean_literal]
    deconstruct Extracted
        'false

    replace [repeat openHAB_declaration_or_statement]
        'if '( Condition [condition] ')
            Statement [statement]

    where not
        Statement [isBlock]
        
    construct StatementCast [openHAB_declaration_or_statement]
        Statement

    construct ProcessedStatement [repeat openHAB_declaration_or_statement]
        StatementCast [extractActionFunctionValue] [extractActionMethodValue]
                        [keepSingleIfAction] [keepSingleIfNotAction Condition]
    by
        ProcessedStatement
end function

function multiLineIf
    %%% Skip processing if statements if extraction already complete
    import Extracted [boolean_literal]
    deconstruct Extracted
        'false

    replace [repeat openHAB_declaration_or_statement]
        'if '( Condition [condition] ') '{ 
            Statements [repeat declaration_or_statement]
        '}
    
    construct EmptyStatements [repeat openHAB_declaration_or_statement]
        % Empty
    construct ProcessedIfBlockStatements [repeat openHAB_declaration_or_statement]
        EmptyStatements [processIfBlockStatements each Statements]

    construct ProcessedIfStatement [repeat openHAB_declaration_or_statement]
        ProcessedIfBlockStatements [keepMultiIfAction] [keepMultiIfNotAction Condition]

    by
        ProcessedIfStatement
end function

function ifElse
    %%% Skip processing if statements if extraction already complete
    import Extracted [boolean_literal]
    deconstruct Extracted
        'false

    replace [repeat openHAB_declaration_or_statement]
        'if '( Condition [condition] ') '{
            IfStatements [repeat declaration_or_statement]
        '}
        'else '{
            ElseStatements [repeat declaration_or_statement]
        '}

    construct EmptyIfStatements [repeat openHAB_declaration_or_statement]
        % empty
    construct ProcessedIfStatements [repeat openHAB_declaration_or_statement]
        EmptyIfStatements [processIfElseIfStatements each IfStatements] 
    construct ProcessedIfConstruct [repeat openHAB_declaration_or_statement]
        ProcessedIfStatements [keepMultiIfAction] [keepMultiIfNotAction Condition]

    construct EmptyElseStatements [repeat openHAB_declaration_or_statement]
        % empty
    construct PreparedElseStatements [repeat declaration_or_statement]
        ElseStatements [actionFoundInIf] [actionNotFoundInIf] 
    construct ProcessedElseStatements [repeat openHAB_declaration_or_statement]
        EmptyElseStatements [processIfElseElseStatements each PreparedElseStatements]
    construct ProcessedElseConstruct [repeat openHAB_declaration_or_statement]
        ProcessedElseStatements [keepMultiIfAction] [keepMultiElseNotAction]

    construct EmptyIfElseConstruct [repeat openHAB_declaration_or_statement]
        % empty
    construct ProcessedIfElseConstruct [repeat openHAB_declaration_or_statement]
        EmptyIfElseConstruct    [addIfElseConstruct ProcessedIfConstruct ProcessedElseConstruct]
                                [addOnlyIfStatements ProcessedIfConstruct ProcessedElseConstruct]
                                [addOnlyElseStatements ProcessedIfConstruct ProcessedElseConstruct]

    by
        ProcessedIfElseConstruct
end function


%%%%%%%%%%%%%%
% NESTED IF MAINS
%%%%
function singleLineNest
    %%% Skip processing if statements if extraction already complete
    import Extracted [boolean_literal]
    deconstruct Extracted
        'false

    replace [repeat openHAB_declaration_or_statement]
        'if '( Condition [condition] ')
            Statement [statement]

    where not
        Statement [isBlock]
        
    construct StatementCast [repeat openHAB_declaration_or_statement]
        Statement

    construct ProcessedStatement [repeat openHAB_declaration_or_statement]
        StatementCast [singleLineIf] [multiLineIf] [ifElse]
                        [keepSingleIfAction] [keepSingleIfNotAction Condition]
    by
        ProcessedStatement
end function

function multiLineNest
    %%% Skip processing if statements if extraction already complete
    import Extracted [boolean_literal]
    deconstruct Extracted
        'false

    replace [repeat openHAB_declaration_or_statement]
        'if '( Condition [condition] ') '{ 
            Statements [repeat declaration_or_statement]
        '}
    
    construct EmptyStatements [repeat openHAB_declaration_or_statement]
        % Empty
    construct ProcessedIfBlockStatements [repeat openHAB_declaration_or_statement]
        EmptyStatements [processNestedIfBlockStatements each Statements]

    construct ProcessedIfStatement [repeat openHAB_declaration_or_statement]
        ProcessedIfBlockStatements [keepMultiIfAction] [keepMultiIfNotAction Condition]

    by
        ProcessedIfStatement
end function

function ifElseNest
    %%% Skip processing if statements if extraction already complete
    import Extracted [boolean_literal]
    deconstruct Extracted
        'false

    replace [repeat openHAB_declaration_or_statement]
        'if '( Condition [condition] ') '{
            IfStatements [repeat declaration_or_statement]
        '}
        'else '{
            ElseStatements [repeat declaration_or_statement]
        '}

    construct EmptyIfStatements [repeat openHAB_declaration_or_statement]
        % empty
    construct ProcessedIfStatements [repeat openHAB_declaration_or_statement]
        EmptyIfStatements [processNestedIfElseIfStatements each IfStatements] 
    construct ProcessedIfConstruct [repeat openHAB_declaration_or_statement]
        ProcessedIfStatements [keepMultiIfAction] [keepMultiIfNotAction Condition]
    

    construct EmptyElseStatements [repeat openHAB_declaration_or_statement]
        % empty
    construct PreparedElseStatements [repeat declaration_or_statement]
        ElseStatements [actionFoundInIf] [actionNotFoundInIf] 
    construct ProcessedElseStatements [repeat openHAB_declaration_or_statement]
        EmptyElseStatements [processNestedIfElseElseStatements each PreparedElseStatements]
    construct ProcessedElseConstruct [repeat openHAB_declaration_or_statement]
        ProcessedElseStatements [keepMultiIfAction] [keepMultiElseNotAction]

    construct EmptyIfElseConstruct [repeat openHAB_declaration_or_statement]
        % empty
    construct ProcessedIfElseConstruct [repeat openHAB_declaration_or_statement]
        emptyIfElseConstruct    [addIfElseConstruct ProcessedIfConstruct ProcessedElseConstruct]
                                [addOnlyIfStatements ProcessedIfConstruct ProcessedElseConstruct]
                                [addOnlyElseStatements ProcessedIfConstruct ProcessedElseConstruct]

    by
        ProcessedIfElseConstruct
end function



%%%%%%%%%%%%%%
% IF ELSE PROCESSING SECONDARY
%%%%
function processIfBlockStatements Statement [declaration_or_statement]
    replace [repeat openHAB_declaration_or_statement]
        Statements [repeat openHAB_declaration_or_statement]

    construct StatementCast [openHAB_declaration_or_statement]
        Statement        

    construct ProcessedStatement [openHAB_declaration_or_statement]
        StatementCast   [extractActionFunctionValue] [extractActionMethodValue]
                        [keepStatement]
    by
        Statements [. ProcessedStatement]
end function

function processIfElseIfStatements Statement [declaration_or_statement]    
    replace [repeat openHAB_declaration_or_statement]
        Statements [repeat openHAB_declaration_or_statement]

    construct StatementCast [openHAB_declaration_or_statement]
        Statement        

    construct ProcessedStatement [openHAB_declaration_or_statement]
        StatementCast   [extractActionFunctionValue] [extractActionMethodValue]
                        [keepStatement]
    by
        Statements [. ProcessedStatement]
end function

function processIfElseElseStatements Statement [declaration_or_statement]   
    replace [repeat openHAB_declaration_or_statement]
        Statements [repeat openHAB_declaration_or_statement]

    construct StatementCast [openHAB_declaration_or_statement]
        Statement        

    construct ProcessedStatement [openHAB_declaration_or_statement]
        StatementCast   [extractActionFunctionValue] [extractActionMethodValue]
                        [keepStatement]
    by
        Statements [. ProcessedStatement]
end function


function processNestedIfBlockStatements Statement [declaration_or_statement]
    replace [repeat openHAB_declaration_or_statement]
        Statements [repeat openHAB_declaration_or_statement]

    construct StatementCast [repeat openHAB_declaration_or_statement]
        Statement        

    construct ProcessedStatement [repeat openHAB_declaration_or_statement]
        StatementCast   [singleLineIf] [multiLineIf] [ifElse]
    by
        Statements [. ProcessedStatement]
end function

function processNestedIfElseIfStatements Statement [declaration_or_statement]  
    replace [repeat openHAB_declaration_or_statement]
        Statements [repeat openHAB_declaration_or_statement]

    construct StatementCast [repeat openHAB_declaration_or_statement]
        Statement        

    construct ProcessedStatement [repeat openHAB_declaration_or_statement]
        StatementCast   [singleLineIf] [multiLineIf] [ifElse]
    by
        Statements [. ProcessedStatement]
end function

function processNestedIfElseElseStatements Statement [declaration_or_statement]
    replace [repeat openHAB_declaration_or_statement]
        Statements [repeat openHAB_declaration_or_statement]

    construct StatementCast [repeat openHAB_declaration_or_statement]
        Statement        

    construct ProcessedStatement [repeat openHAB_declaration_or_statement]
        StatementCast   [singleLineIf] [multiLineIf] [ifElse]
    by
        Statements [. ProcessedStatement]
end function



%%%%%%%%%%%%%%
% HELPERS
%%%%
function addOnlyIfStatements ProcessedIfConstruct [repeat openHAB_declaration_or_statement] ProcessedElseConstruct [repeat openHAB_declaration_or_statement]
    where not
        ProcessedIfConstruct [isIfStatement]
    where not
        ProcessedElseConstruct [isIfStatement]
    replace [repeat openHAB_declaration_or_statement]
        IfElseConstruct [repeat openHAB_declaration_or_statement]
    by
        ProcessedIfConstruct     
end function

function addOnlyElseStatements ProcessedIfConstruct [repeat openHAB_declaration_or_statement] ProcessedElseConstruct [repeat openHAB_declaration_or_statement]
    where
        ProcessedIfConstruct [isIfStatement]
    where not
        ProcessedElseConstruct [isIfStatement]
    replace [repeat openHAB_declaration_or_statement]
        IfElseConstruct [repeat openHAB_declaration_or_statement]
    by
        ProcessedElseConstruct
end function

function addIfElseConstruct ProcessedIfConstruct [repeat openHAB_declaration_or_statement] ProcessedElseConstruct [repeat openHAB_declaration_or_statement]
    replace [repeat openHAB_declaration_or_statement]
        IfElseConstruct [repeat openHAB_declaration_or_statement]
    deconstruct ProcessedIfConstruct
        'if '( Condition [condition] ') '{
            IfStatements [repeat declaration_or_statement]
        '}
    deconstruct ProcessedElseConstruct
        'if '( _ [condition] ') '{
            ElseStatements [repeat declaration_or_statement]
        '}

    by
        'if '( Condition ') '{
            IfStatements
        '}
        'else '{
            ElseStatements
        '}   
end function







%%%%%%%%%%%%%%
% KEEPERS
%%%%
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

function keepMultiElseNotAction
    import Extracted [boolean_literal]
    deconstruct Extracted
        'false

    replace [repeat openHAB_declaration_or_statement]
        Statements [repeat openHAB_declaration_or_statement]
    
    construct emptyDOS [repeat declaration_or_statement]
        % empty
    construct DOSCast [repeat declaration_or_statement]
        emptyDOS [castToDOS each Statements]
        
    construct PlaceholderElseStatement [repeat openHAB_declaration_or_statement]
        'if '( 'empty ') '{
            DOSCast
        '}
    by
        PlaceholderElseStatement
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

function keepStatements
    replace [repeat openHAB_declaration_or_statement]
        Statements [repeat openHAB_declaration_or_statement]
    by
        Statements
end function




function castToDOS Statement [openHAB_declaration_or_statement]
    replace [repeat declaration_or_statement]
        DOS [repeat declaration_or_statement]
    deconstruct Statement
        DecOrState [declaration_or_statement]
    by
        DOS [. DecOrState]
end function

function isBlock
    match [statement]
        Statement [statement]
    deconstruct Statement
        '{ 
            DeclsOrStates [repeat declaration_or_statement]
        '}
end function

function isIfStatement
    match [repeat openHAB_declaration_or_statement]
        'if '( _ [condition] ') '{
            _ [repeat declaration_or_statement]
        '}
end function
