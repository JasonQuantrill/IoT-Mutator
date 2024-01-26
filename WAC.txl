% TXL OpenHAB Rules Grammar
include "openhab.grm"
include "extractTriggerData.txl"


%%% Work still to do:
% create pattern matches for additional trigger patterns
%       opt state
%       opt command
%       changed
%       time & system based trigs
% pattern matches for all action patterns
% ensuring different values
% ensure compatible triggers



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
        Rules [modifyAction] [ensureCompatibleTriggers]
    
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

    construct exportItem [repeat openHAB_declaration_or_statement]
        StatementsA [exportItemA1]

    construct ModifiedStatements [repeat openHAB_declaration_or_statement]
        StatementsB [changeItemB1]

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

function exportItemA1
    replace * [statement]
        Action [id]
        '( ItemA1 [expression], Value [expression] ')

    export ItemA1

    by
        Action '( ItemA1, Value )
end function


function changeItemB1
    import ItemA1 [expression]

    replace * [statement]
        Action [id]
        '( ItemB1 [expression], Value [expression] ')

    %where not
        %ItemB1 [sameItem ItemA1]

    by
        Action '( ItemA1, Value )
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

    %%% To extract Item and Value as global variables
    construct _ [trigger_condition]
        TriggerA [extractTriggerData]

    %%% To perform all checks and edit Trigger Value if necessary
    construct ModifiedTriggerB [trigger_condition]
        TriggerB [modifyTrigger]

    by
        RuleA
        RuleB
        RestB
end function





function modifyTrigger
    replace [trigger_condition]
        Trigger [trigger_condition]

    %%% If these all fail, it means the triggers depend on different Items, and therefore are already compatible
    construct TriggerBRC [trigger_condition]
        Trigger [changeTriggerRC]
    construct TriggerBRU [trigger_condition]
        Trigger [changeTriggerRU]

    by
        Trigger
end function


function changeTriggerRC
    import TriggerItem [id]
    
    replace [trigger_condition]
        'Item ItemId [id]
        'received 'command
        Command [opt command]

    where
        ItemId [= TriggerItem]

    by
        'Item TriggerItem
        'received 'command
        Command
end function


function changeTriggerRU
    import TriggerItem [id]
    
    replace [trigger_condition]
        'Item ItemId [id]
        'received 'update
        State [opt state]
    
    where
        ItemId [= TriggerItem]

    by
        'Item TriggerItem
        'received 'update
        State
end function

function ensureCompatibleTriggerValues
    replace [trigger_condition]
        Trigger [trigger_condition]
    by
        Trigger
end function

