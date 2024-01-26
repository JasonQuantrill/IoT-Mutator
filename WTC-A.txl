% TXL OpenHAB Rules Grammar
include "openhab.grm"


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







function extractTriggerData
    replace [trigger_condition]
        Trigger [trigger_condition]

    %%% Multiple functions to try to match different trigger patterns. Only 1 will succeed.
    %%% Different patterns include "received command", "post update ON", "changed to ON", etc
    %%% Export function extracts the trigger data as global variables so they can be used in the replacement
    construct _ [trigger_condition]
        Trigger [exportTriggerRCItem] [exportTriggerRUItem] [exportTriggerCItem]
                [exportTriggerRCItemValue] [exportTriggerRUItemValue] [exportTriggerCItemValue]

    by  
        Trigger
end function


function exportTriggerRCItem
    replace [trigger_condition]
        'Item TriggerItem [id]
        'received 'command

    export TriggerItem

    by
        'Item TriggerItem
        'received 'command
end function

function exportTriggerRCItemValue
    replace [trigger_condition]
        'Item TriggerItem [id]
        'received 'command
        TriggerTo [opt command]

    deconstruct TriggerTo
        TriggerToValue [id]

    export TriggerItem
    export TriggerToValue

    by
        'Item TriggerItem
        'received 'command
        TriggerTo
end function

function exportTriggerRUItem
    replace [trigger_condition]
        'Item TriggerItem [id]
        'received 'update

    export TriggerItem
    
    by
        'Item TriggerItem
        'received 'update
end function

function exportTriggerRUItemValue
    replace [trigger_condition]
        'Item TriggerItem [id]
        'received 'update
        TriggerTo [opt state]

     deconstruct TriggerTo
        TriggerToValue [id]

    export TriggerItem
    export TriggerToValue
    
    by
        'Item TriggerItem
        'received 'update
        TriggerTo
end function

function exportTriggerCItem
    replace [trigger_condition]
        'Item TriggerItem [id]
        'changed

    export TriggerItem
    
    by
        'Item TriggerItem
        'changed
end function

function exportTriggerCItemValue
    replace [trigger_condition]
        'Item TriggerItem [id]
        'changed
        TriggerFrom [opt from_range]
        TriggerTo [opt to_range]

    deconstruct TriggerTo
        'to TriggerToValue [id]

    export TriggerItem
    export TriggerToValue
    
    by
        'Item TriggerItem
        'changed
        TriggerFrom
        TriggerTo
end function