% TXL OpenHAB Rules Grammar
include "openhab.grm"
include "extractTriggerData.txl"


%%% Weak Trigger Cascade - Action
% Modify Action
% Ensure Compatible Conditions


function main

    %%% Define global variables
    %%% Construct and export with "nothing" id
    construct TriggerItem [id]
        nothing
    export TriggerItem
    construct TriggerToValue [id]
        nothing
    export TriggerToValue

    replace [program] 
        P [program]
    construct NewP [program]
        P [createWeakTriggerCascade]
    by
        NewP
end function


function createWeakTriggerCascade
    replace [program]
        Package [opt package_header]
        Import [repeat import_declaration]
        Declares [repeat variable_declaration]
        Rules [repeat OpenHAB_rule]

    construct ModifiedRules [repeat OpenHAB_rule]
        Rules [modifyAction]

    by
        Package
        Import
        Declares
        ModifiedRules
end function


function modifyAction
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

    deconstruct ScriptA
        StatementsA [repeat openHAB_declaration_or_statement]
    deconstruct ScriptB
        StatementsB [repeat openHAB_declaration_or_statement]

    %%% Extract data from second trigger
    construct _ [trigger_condition]
        TriggerB [extractTriggerData]

    construct ModifiedStatements [repeat openHAB_declaration_or_statement]
        StatementsA [changeActionFunctionItemValue] [changeActionFunctionItem]
    
    by
        'rule NameA
        'when
            TriggerA
            MoreTCA
        'then 
            ModifiedStatements
        'end

        'rule NameB
        'when
            TriggerB
            MoreTCB
        'then 
            ScriptB
        'end
        RestB
end function
    

function changeActionFunctionItemValue
    replace * [statement]
        Action [id]
        '( ItemB1 [expression], Value [expression] ')

    import TriggerItem [id]
    import TriggerToValue [id]

    where not
        TriggerToValue [= "nothing"]

    by
        Action '( TriggerItem, TriggerToValue ')
end function

function changeActionFunctionItem
    replace * [statement]
        Action [id]
        '( ItemB1 [expression], Value [expression] ')

    import TriggerItem [id]
    import TriggerToValue [id]

    where
        TriggerToValue [= "nothing"]

    by
        Action '( TriggerItem, Value ')
end function







