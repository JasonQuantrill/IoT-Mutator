% TXL OpenHAB Rules Grammar
include "Dependencies/openhab.grm"
include "Mutator-Functions/extractTriggerData.txl"
include "Mutator-Functions/extractActionData.txl"
include "Mutator-Functions/extractConditionData.txl"
include "Mutator-Functions/modifyAction.txl"
include "Mutator-Functions/modifyTrigger.txl"
include "Mutator-Functions/modifyConditions.txl"


function main

    %%% Defining global variables
    % Construct and export with "nothing" id
    construct ReplacementItem [id]
        nothing
    export ReplacementItem
    construct ReplacementValue [id]
        nothing
    export ReplacementValue

    replace [program] 
        P [program]
    construct NewP [program]
        P [createWeakActionContradiction]
    by
        NewP
end function


function createWeakActionContradiction
    replace [program]
        Package [opt package_header]
        Import [repeat import_declaration]
        Declares [repeat variable_declaration]
        Rules [repeat OpenHAB_rule]

    construct ModifiedRules  [repeat OpenHAB_rule]
        Rules   [modifyActionWithActionData]
                [ensureCompatibleTriggers]
                [identicalConditions]
    
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

    deconstruct ScriptB
        StatementsB [repeat openHAB_declaration_or_statement]

    construct _ [script_block]
        ScriptA [extractActionData]

    construct ModifiedScript [script_block]
        ScriptB [modifyActionOpposite]

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
            ModifiedScript
        'end
        RestB
end function


function ensureCompatibleTriggers
    
    %%% Resetting global variables
    % Construct and export with "nothing" id
    construct ReplacementItem [id]
        nothing
    export ReplacementItem
    construct ReplacementValue [id]
        nothing
    export ReplacementValue
    
    
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

    %%% To extract Item and ReplacementValue as global variables
    construct _ [trigger_condition]
        TriggerA [extractTriggerData]

    %%% To perform all checks and edit Trigger Value if necessary
    construct ModifiedTriggerB [trigger_condition]
        TriggerB [modifyCompatibleTrigger]

    by
        RuleA
        'rule NameB
        'when
            ModifiedTriggerB
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


    