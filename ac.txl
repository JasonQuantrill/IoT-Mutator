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
        %RuleA [OpenHAB_rule]
        %RuleB [OpenHAB_rule]
        Rules [repeat OpenHAB_rule]

    %deconstruct Rules
        %RuleA [OpenHAB_rule] Rest [repeat OpenHAB_rule]

    construct ModifiedRules [repeat OpenHAB_rule]
        Rules [modifyRules]

    by
        Package
        Import
        Declares
        ModifiedRules
end function

function modifyRules
    replace [repeat OpenHAB_rule]
        'rule Name [stringlit]
        'when
            Trigger [trigger_condition]
            MoreTC [repeat moreTC]
        'then 
            Script [script_block]
        'end

    deconstruct Script
        Statements [repeat statement]

    construct exportItem [repeat statement]
        Statements [exportItem]

    construct ModifiedStatements [repeat statement]
        Statements [changeItem]

    by
        'rule Name
        'when
            Trigger
            MoreTC
        'then 
            ModifiedStatements
        'end
end function


function exportItem
    replace * [statement]
        Action [id]
        '( ItemA [expression], Value [expression] ')

    export ItemA [expression]

    by
        Action '( Other_Item, Value )
end function

function arbMatch
    match [unary_expression]
        postUpdate (nSensor_Living_Temp, temp)
end function

function changeItem
    import ItemA [expression]

    replace * [statement]
        Action [id]
        '( ItemB [expression], Value [expression] ')

    where not
        ItemB [sameItem ItemA]

    by
        Action '( ItemA, Value )
end function

function sameItem Item [expression]
    match [expression]
        Item
end function