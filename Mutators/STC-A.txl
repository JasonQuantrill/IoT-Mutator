% TXL OpenHAB Rules Grammar
include "Dependencies/openhab.grm"
include "Mutator-Functions/extractTriggerData.txl"
include "Mutator-Functions/modifyAction.txl"
include "Mutator-Functions/extractConditionData.txl"
include "Mutator-Functions/modifyConditions.txl"


function main

    %%% Defining global variables for extractTriggerData
    %%% Construct and export with "nothing" id
    construct ReplacementItem [id]
        nothing
    export ReplacementItem
    construct ReplacementValue [id]
      nothing
    export ReplacementValue

    replace [program] 
        P [program]
    construct NewP [program]
        P [createStrongTriggerCascade]
    by
        NewP
end function


function createStrongTriggerCascade
    replace [program]
        Package [opt package_header]
        Import [repeat import_declaration]
        Declares [repeat variable_declaration]
        Rules [repeat OpenHAB_rule]

    construct ModifiedRules [repeat OpenHAB_rule]
        Rules   [modifyActionWithTriggerData]
                [removeConditions]

    by
        Package
        Import
        Declares
        ModifiedRules
end function


function modifyActionWithTriggerData
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
        

    %%% Extract data from trigger
    construct _ [trigger_condition]
        TriggerB [extractTriggerData]

    %%% Modify action with data from trigger
    construct ModifiedScript [script_block]
        ScriptA [modifyAction]
    
    
    by
        'rule NameA
        'when
            TriggerA
            MoreTCA
        'then 
            ModifiedScript
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

function removeConditions
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
        ScriptA [removeConditions2]
    construct ModifiedScriptB [script_block]
        ScriptB [removeConditions2]

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







