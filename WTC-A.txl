% TXL OpenHAB Rules Grammar
include "openhab.grm"

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
        Rules [forceIdenticalTriggers]

    by
        Package
        Import
        Declares
        ModifiedRules
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
            MoreTCB
        'then 
            ScriptB
        'end
        RestB

end function
    





function modifyRules
    replace [repeat OpenHAB_rule]
        'rule Name [rule_id]
        'when
            Trigger [trigger_condition]
            MoreTC [repeat moreTC]
        'then 
            Script [script_block]
        'end
    
    construct NewTrigger [trigger_condition]
        Trigger [changeTriggerItem]
    
    by
        'rule Name
        'when
            NewTrigger
            MoreTC
        'then
            Script
        'end
end function


function changeTriggerItem
    replace [trigger_condition]
        'Item ItemId [id]
        'received 'update
    by
        'Item ItemId123
        'received 'update
end function