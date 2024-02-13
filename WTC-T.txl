% TXL OpenHAB Rules Grammar
include "openhab.grm"
include "extractActionData.txl"
include "modifyTrigger.txl"
include "extractConditionData.txl"
include "modifyConditions.txl"


function main

    %%% Defining global variables for extractActionData
    %%% Construct and export with "nothing" id
    construct ReplacementItem [id]
        nothing
    export ReplacementItem
    construct ReplacementValue [id]
      nothing
    export ReplacementValue
    construct ReplacementAction [id]
      nothing
    export ReplacementAction

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
        Rules   [modifyTriggerWithActionData]
                [identicalConditions]

    by
        Package
        Import
        Declares
        ModifiedRules
end function


function modifyTriggerWithActionData
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
        

    %%% Extract data from action
    construct _ [script_block]
        ScriptA [extractActionData]

    %%% Modify trigger with data from action
    construct ModifiedTrigger [trigger_condition]
        TriggerB [modifyTrigger]
    
    
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
            ModifiedTrigger
            MoreTCB
        'then 
            ScriptB
        'end
        RestB
end function

function identicalConditions
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

    construct _ [script_block]
        ScriptA [extractConditionData]
    construct ModifiedScriptB [script_block]
        ScriptB [identicalConditions2]

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
            TriggerB
            MoreTCB
        'then 
            ModifiedScriptB
        'end
        RestB
end function







