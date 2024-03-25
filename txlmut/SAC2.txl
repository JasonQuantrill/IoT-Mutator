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

    %%% Process each statement one by one:
    construct EmptyStatements [repeat openHAB_declaration_or_statement]
        % none
    construct FirstSweepStatements [repeat openHAB_declaration_or_statement]
        EmptyStatements [processActionStatement each Statements]

    construct PrepareForSecondSweep [repeat openHAB_declaration_or_statement]
        FirstSweepStatements [actionFound] [actionNotFoundYet]

    construct SecondSweepStatements [repeat openHAB_declaration_or_statement]
        PrepareForSecondSweep [processIfStatement each Statements]
  
    by
        SecondSweepStatements   
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
    %construct StatementCast [repeat openHAB_declaration_or_statement]
        %Statement

    %%% this function looks at each statement
    %%% if the statement is an if statement
    construct ProcessedStatement [openHAB_declaration_or_statement]
        Statement   [singleLineIf] %[multiLineIf]
                    [keepStatement]
                    
    
    by
        Statements [. ProcessedStatement]
end function


function singleLineIf
    %%% Skip processing if statements if extraction already complete
    import Extracted [boolean_literal]
    deconstruct Extracted
        'false

    replace [openHAB_declaration_or_statement]
        'if '( Condition [condition] ')
            Statement [statement]
        
    construct StatementCast [openHAB_declaration_or_statement]
        Statement

    construct ProcessedStatement [openHAB_declaration_or_statement]
        StatementCast [extractActionFunctionValue] [extractActionMethodValue]
                        [keepIfAction] [keepIfNotAction Condition]
    by
        ProcessedStatement
end function

function keepIfNotAction Condition [condition]
    replace [openHAB_declaration_or_statement]
        Statement [openHAB_declaration_or_statement]
    
    import Extracted [boolean_literal]
    deconstruct Extracted
        'false

    deconstruct Statement 
        StatementCast [statement]
    construct OriginalIfStatement [openHAB_declaration_or_statement]
        'if '( Condition ')
            StatementCast
    by
        OriginalIfStatement
end function

function keepIfAction
    replace [openHAB_declaration_or_statement]
        Statement [openHAB_declaration_or_statement]
    
    import Extracted [boolean_literal]
    deconstruct Extracted
        'true
    by
        Statement
end function

%function multiLineIf
 %   replace [repeat openHAB_declaration_or_statement]
  %      'if '( Condition [condition] ')
   %         Block [block]
%
 %   deconstruct Block
  %      '{ 
   %         DeclsOrStates [repeat declaration_or_statement]
    %    '}
     %       
%    construct EmptyStatements [repeat openHAB_declaration_or_statement]
 %       % Empty
  %  construct ExtractedStatements [repeat openHAB_declaration_or_statement]
   %     EmptyStatements %[extractStatements each DeclsOrStates]
%
 %   by
  %      ExtractedStatements
%end function


function keepStatement
    replace [openHAB_declaration_or_statement]
        Statement [openHAB_declaration_or_statement]
    by
        Statement
end function