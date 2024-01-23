% TXL OpenHAB Rules Grammar
include "openhab.grm"

function main
    replace [program] 
        P [program]
    construct NewP [program]
        P [changeRule]
    by
        NewP
end function


function changeRule
    replace [program]
        Package [opt package_header]
        Import [repeat import_declaration]
        Declares [repeat variable_declaration]
        Rules [repeat OpenHAB_rule]

    construct ModifiedRules [repeat OpenHAB_rule]
        Rules [modifyRules]

    %deconstruct Rules
        %RuleA [OpenHAB_rule] Rest [repeat OpenHAB_rule]
    by
        Package
        Import
        Declares
        ModifiedRules
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