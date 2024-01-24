% TXL OpenHAB Rules Grammar
include "openhab.grm"

function main
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
        Rules [changeAction] [ensureCompatibleTriggers]
    
    by
        Package
        Import
        Declares
        ModifiedRules
end function


function changeAction
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

    construct exportItem [repeat openHAB_declaration_or_statement]
        StatementsA [exportItemA]

    construct ModifiedStatements [repeat openHAB_declaration_or_statement]
        StatementsB [changeItemB]

    by
        'rule NameA
        'when
            TriggerA
            MoreTCA
        'then 
            StatementsA
        'end

        'rule NameB
        'when
            TriggerB
            MoreTCB
        'then 
            ModifiedStatements
        'end
        RestB
end function

function exportItemA
    replace * [statement]
        Action [id]
        '( ItemA [expression], Value [expression] ')

    export ItemA

    by
        Action '( ItemA, Value )
end function


function changeItemB
    import ItemA [expression]

    replace * [statement]
        Action [id]
        '( ItemB [expression], Value [expression] ')

    %where not
        %ItemB [sameItem ItemA]

    by
        Action '( ItemA, Value )
end function

function ensureCompatibleTriggers
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

    construct TriggerARC [trigger_condition]
        TriggerA [triggerRC]
    construct TriggerARU [trigger_condition]
        TriggerA [triggerRU]

    by
        RuleA
        RuleB
        RestB
end function

function triggerRC
    replace [trigger_condition]
        'Item ItemId [id]
        'received 'command
        Command [opt command]

    by
        'Item ItemId
        'received 'command
        Command
end function

function triggerRU
    replace [trigger_condition]
        'Item ItemId [id]
        'received 'update
        State [opt state]

    by
        'Item ItemId
        'received 'update
        State
end function
