import os
import re
import random
import subprocess

# Clear terminal
os.system('cls' if os.name == 'nt' else 'clear')


def get_rules(rules_file):
    # Open the .rules file in read mode
    with open(f'Rulesets/{rules_file}.rules', 'r') as file:
        # Read the contents of the file
        file_contents = file.read()
    return file_contents
    
def separate_rules(rules):
    # Initialize an empty list to store each rule
    rules_list = []
    
    # # Remove block comments
    # file_contents = re.sub(r'/\*\*.*?\*/', '', file_contents, flags=re.DOTALL)

    # Split the content by 'end' to get individual blocks, assuming each rule ends with 'end'
    rules = rules.split('\nend')

    # Process each block to extract the rule (assuming each rule starts with "rule")
    for rule in rules:
        # Trim whitespace
        trimmed_block = rule.strip()

        if trimmed_block:
            # Remove line comments
            trimmed_block = re.sub(r'//.*', '', trimmed_block)

            # Find the index of the first occurrence of "rule" in the block
            rule_start_index = trimmed_block.find('rule "')

            # Check if "rule" is found and not at the beginning
            if rule_start_index != -1:
                # Extract the rule starting from "rule" to the end of the block
                rule = trimmed_block[rule_start_index:] + '\nend'  # Append 'end' back to the rule
                rules_list.append(rule)
    return rules_list


def mutate_rules(rules_list, rule_A, rule_B, mutation_mode):
    # Write the original rules to file
    with open('original.rules', 'w') as file:
        file.write(rules_list[rule_A] + '\n\n' + rules_list[rule_B])

    # Apply the TXL mutator    
    mutated_rules = subprocess.run(['txl', 'original.rules', f'txlmut/{mutation_mode}.txl'], stdout=subprocess.PIPE).stdout.decode('utf-8')

    # Separate mutated rule string back into 2 distinct rules
    mutated_rules = separate_rules(mutated_rules.replace('\r\n', '\n'))

    # Write the mutated rules to file
    with open('mutated.rules', 'w') as file:
        file.write(mutated_rules[0] + '\n\n' + mutated_rules[1])
    
    return mutated_rules


def choose_rules(rules_list, mutation_mode):
    # Determine eligible rules that function with txl mutator
    eligible_rule_A, eligible_rule_B = determine_rule_eligibility(rules_list, mutation_mode)

    # From eligible rules, select the indices of 2 rules to mutate
    if len(eligible_rule_B) == 1:
        rule_B = eligible_rule_B[0]
        if rule_B in eligible_rule_A:
            eligible_rule_A.remove(rule_B)
        rule_A = random.choice(eligible_rule_A)
    else:
        rule_A = random.choice(eligible_rule_A)
        if rule_A in eligible_rule_B:
            eligible_rule_B.remove(rule_A)
        rule_B = random.choice(eligible_rule_B)
    
    print(f'\nSelected rules {rule_A} and {rule_B}\n')

    return rule_A, rule_B

def determine_rule_eligibility(rules_list, mutation_mode):
    eligible_rules_A = []
    eligible_rules_B = []

    (patterns_A, patterns_B,
    exclusion_patterns_A, exclusion_patterns_B) = (
        get_rule_patterns(mutation_mode))

    for i in range(len(rules_list)):
        # Exclude rules for A with this kind of pattern
        exclusion_found_A = any(re.findall(ex_pattern, rules_list[i]) for ex_pattern in exclusion_patterns_A)
        if not exclusion_found_A:
            # If not excluded for A, check if it matches any pattern for A
            if any(re.findall(pattern, rules_list[i]) for pattern in patterns_A):
                eligible_rules_A.append(i)
            
        # Exclude rules for B
        exclusion_found_B = any(re.findall(ex_pattern, rules_list[i]) for ex_pattern in exclusion_patterns_B)            
        if not exclusion_found_B:
            # If not excluded for B, check if it matches any pattern for B
            if any(re.findall(pattern, rules_list[i]) for pattern in patterns_B):
                eligible_rules_B.append(i)

        print(i)

    print('\nRule_A eligible indices: ', eligible_rules_A)
    print('Rule_B eligible indices: ', eligible_rules_B)
    
    return eligible_rules_A, eligible_rules_B

def get_rule_patterns(mutation_mode):
    # Create pattern lists to be returned: 
    # Patterns for rule_A, rule_B, and patterns that txl will not parse, and so must be excluded
    patterns_A = []
    patterns_B = []
    exclusion_patterns_A = []
    exclusion_patterns_B = []

    # Create list of different formats of action commands
    commands = ['sendCommand', 'postUpdate']
    command_patterns = '(' + '|'.join(commands) + ')'

    # Create list of different formats of action values
    values = ['ON', 'OFF', 'OPEN', 'CLOSED']
    value_patterns = '(' + '|'.join(values) + ')'

    # Create regex patterns
    # eg. when\n TRIGGER\n then\n
    # trigger_pattern_general = r'when\n(\t| +)(.+)\nthen\n'
    trigger_pattern_general = re.compile(r'when(.*)then', re.DOTALL)
    # eg. System started
    # Note: this pattern could be allowed if the first trigger is also 'System started'
    #       but for now the pattern is just excluded
    trigger_pattern_system = re.compile(r'when(.*)System started(.*)then', re.DOTALL)

    # eg. Item GroupIrrigationValves changed
    trigger_pattern_item = re.compile(r'when(.*)Item(.*)then', re.DOTALL)
    

    # eg. Item.postUpdate(OFF)
    action_method_value = (r'(.+)\.' + command_patterns + r'\((' + value_patterns + r')\)')
    # eg. postUpdate(Item, OFF)   
    action_function_value = ('(' + command_patterns + ')' + r'\(' + r'(.+), *' + r'(' + value_patterns + r')\)')

    # eg. Item.postUpdate(Any.Value) OR Item.postUpdate(OFF)
    action_method_general = (r'(.+)\.' + command_patterns + r'\(' + r'(.+)' + r'\)')
    # eg. postUpdate(Item, Any.Value) OR postUpdate(Item, OFF) 
    action_function_general = (command_patterns + r'\(' + r'(.+) *,' + r'(.+)\)')

    # Right now just catches all conditions
    # Need it to catch only when an action is nested inside a condition
    # If it's a condition nested inside another condition, ideally txl changes both
    # Variations include:
    #   single line conditions (no { })
    #   else if (should be caught by regular if)
    #   else (could do regex OR (if|else))
    #   conditions with multiple statements inside
    #       could be caught by { }, but that will be tripped up by nested conditions
    condition_action = (r'if \((.+)\)')

    if mutation_mode == 'SAC' or mutation_mode == 'WAC':
        patterns_A.append(action_method_value)
        patterns_A.append(action_function_value)

        patterns_B.append(action_method_general)
        patterns_B.append(action_function_general)

        if mutation_mode == 'WAC':
            exclusion_patterns_A.append(trigger_pattern_system)
            exclusion_patterns_B.append(trigger_pattern_system)

    elif mutation_mode == 'STC-A' or mutation_mode == 'WTC-A':
        patterns_A.append(trigger_pattern_item)

        patterns_B.append(action_method_general)
        patterns_B.append(action_function_general)

    elif mutation_mode == 'STC-T' or mutation_mode == 'WTC-T':
        patterns_A.append(action_method_value)
        patterns_A.append(action_function_value)

        patterns_B.append(trigger_pattern_general)
    elif mutation_mode == 'WCC':
        patterns_A.append(action_method_general)
        patterns_A.append(action_function_general)

        patterns_B.append(condition_action)

    # eg. TXL won't parse eg. GroupIrrigationTimes.members.findFirst[t | ... ]
    exclusion_patterns_A.append(r'.members')
    exclusion_patterns_B.append(r'.members')

    return patterns_A, patterns_B, exclusion_patterns_A, exclusion_patterns_B,


def main(A=1, B=0, rules_file='demo', mutation_mode='STC-T'):

    # rules_file = 'rulesets/demo.rules'
    rules = get_rules(rules_file)

    # Parse rules file
    rules_list = separate_rules(rules)

    # Select 2 rules to mutate
    rule_A, rule_B = choose_rules(rules_list, mutation_mode)
    rule_A, rule_B = A, B # Testing

    # Perform the mutation
    mutated_rules = mutate_rules(rules_list, rule_A, rule_B, mutation_mode)

    rules_list[rule_A] = mutated_rules[0]
    rules_list[rule_B] = mutated_rules[1]


    print(mutated_rules[0], '\n')
    print(mutated_rules[1])



if __name__ == "__main__":
    main()