include "Dependencies/openhab.grm"

function main
    replace [program] 
        P [program]
    construct NewP [program]
        P [parseProgram]
    by
        NewP
end function

function parseProgram
    replace [program]
        Package [opt package_header]
        Import [repeat import_declaration]
        Declares [repeat variable_declaration]
        Rules [repeat OpenHAB_rule]

    construct ModifiedRules  [repeat OpenHAB_rule]
        Rules   [parseRules]
    
    by
        Package
        Import
        Declares
        ModifiedRules
end function


function parseRules
    replace [repeat OpenHAB_rule]
        RuleA [OpenHAB_rule] RestA [repeat OpenHAB_rule]

    deconstruct RuleA
        'rule NameA [rule_id]
        'when
            TriggerA [trigger_condition]
            MoreTCA [repeat moreTC]
        'then 
            ScriptA [script_block]
        'end

    deconstruct ScriptA
        Statements [repeat openHAB_declaration_or_statement]

    construct EmptyStatements [repeat openHAB_declaration_or_statement]
        % none
    construct ProcessedStatements [repeat openHAB_declaration_or_statement]
        EmptyStatements [ProcessStatement each Statements]

    by
        'rule NameA
        'when
            TriggerA
            MoreTCA
        'then 
            ScriptA
        'end
        RestA
end function

function ProcessStatement Statement [openHAB_declaration_or_statement]
    replace [repeat openHAB_declaration_or_statement]
        Statements [repeat openHAB_declaration_or_statement]
    
    by
        Statements [. Statement]
end function