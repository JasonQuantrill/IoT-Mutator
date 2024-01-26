% TXL OpenHAB Rules Grammar
include "openhab.grm"


%%% Weak Trigger Cascade - Action
% Modify Action
% Ensure Compatible Conditions


function main
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
        StatementsA [changeItemB1]
    
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
    

function changeItemB1
    import TriggerItem [id]
    import TriggerToValue [status]

    replace * [statement]
        Action [id]
        '( ItemB1 [expression], Value [expression] ')


    construct TriggerToString [stringlit]
        _ [quote TriggerToValue]
    construct TriggerToExpression [id]
        _ [unquote TriggerToString]
    

    by
        Action '( TriggerItem, TriggerToExpression ')
end function










function extractTriggerData
    replace [trigger_condition]
        Trigger [trigger_condition]

    %%% Multiple constructs to try to match different trigger patterns. Only 1 will succeed.
    %%% Construct only used to call export function and extract the Item as a global variable
    construct _ [trigger_condition]
        Trigger [exportTriggerDataRC] [exportTriggerDataRU] [exportTriggerDataC]

    by  
        Trigger
end function


function exportTriggerDataRC
    replace [trigger_condition]
        'Item TriggerItem [id]
        'received 'command
        TriggerToValue [opt command]

    export TriggerItem

    by
        'Item ItemA2
        'received 'command
        TriggerToValue
end function

function exportTriggerDataRU
    replace [trigger_condition]
        'Item TriggerItem [id]
        'received 'update
        TriggerToValue [opt state]

    export TriggerItem
    
    by
        'Item ItemA2
        'received 'update
        TriggerToValue
end function

function exportTriggerDataC
    replace [trigger_condition]
        'Item TriggerItem [id]
        'changed
        TriggerFrom [opt from_range]
        TriggerTo [opt to_range]

    deconstruct TriggerTo
        'to TriggerToValue [status]

    export TriggerItem
    export TriggerToValue
    
    by
        'Item TriggerItem
        'changed
        TriggerFrom
        TriggerTo
end function