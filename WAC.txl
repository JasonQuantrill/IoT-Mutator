% TXL OpenHAB Rules Grammar
include "openhab.grm"
include "extractTriggerData.txl"
include "extractActionData.txl"
include "modifyAction.txl"


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

    %%% To perform all checks and edit Trigger ReplacementValue if necessary
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





function modifyCompatibleTrigger
    replace [trigger_condition]
        Trigger [trigger_condition]

    %%% If these all fail, it means the triggers depend on different Items, and therefore are already compatible
    construct ModifiedTrigger [trigger_condition]
        Trigger [modifyCompatibleTriggerRC] [modifyCompatibleTriggerRU]
                [passTrigger]

    by
        ModifiedTrigger
end function


function modifyCompatibleTriggerRC    
    replace [trigger_condition]
        'Item ItemId [id]
        'received 'command
        Command [opt command]

    deconstruct Command
        Value [id]

    import ReplacementItem [id]
    import ReplacementValue [id]

    %%% Are the triggers acting on the same item?
    where
        ItemId [= ReplacementItem]
    %%% If first trigger doesn't specify a value, triggers are compatible
    where not
        ReplacementValue [= "nothing"]

    by
        'Item ReplacementItem
        'received 'command
        ReplacementValue
end function


function modifyCompatibleTriggerRU
    import ReplacementItem [id]
    
    replace [trigger_condition]
        'Item ItemId [id]
        'received 'update
        State [opt state]
    
    where
        ItemId [= ReplacementItem]

    by
        'Item ReplacementItem
        'received 'update
        State
end function

function passTrigger

    %%% Passing function to pass original trigger in case no other patterns match
    replace [trigger_condition]
        Trigger  [trigger_condition]
    by
        Trigger
end function


function ensureCompatibleTriggerValues
    replace [trigger_condition]
        Trigger [trigger_condition]
    by
        Trigger
end function
    