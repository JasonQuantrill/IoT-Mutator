import os
import re
import random
import subprocess

# Clear terminal
os.system('cls' if os.name == 'nt' else 'clear')


def get_rules(filename):
    # Open the .rules file in read mode
    with open(rules_file, 'r') as file:
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
    mutated_rules = str(subprocess.run(['txl', 'original.rules', f'txlmut/{mutation_mode}.txl'], stdout=subprocess.PIPE))
    
    # Separate mutated rule string back into 2 distinct rules
    mutated_rules = separate_rules(mutated_rules.replace('\\n', '\n').replace('\\r', '\r'))

    # Write the mutated rules to file
    with open('mutated.rules', 'w') as file:
        file.write(mutated_rules[0] + '\n\n' + mutated_rules[1])
    
    return mutated_rules


def choose_rules(rules_list, mutation_mode):
    # Determine eligible rules that function with txl mutator
    eligible_rule_A, eligible_rule_B = determine_rule_eligibility(rules_list, mutation_mode)

    # From eligible rules, select the indices of 2 rules to mutate
    rule_A = random.choice(eligible_rule_A)

    eligible_rule_B.remove(rule_A)
    rule_B = random.choice(eligible_rule_B)
    
    print(f'\nSelected rules {rule_A} and {rule_B}\n')

    return rule_A, rule_B

def determine_rule_eligibility(rules_list, mutation_mode):
    eligible_rules_A = []
    eligible_rules_B = []

    patterns_A, patterns_B, exclusion_patterns = get_rule_patterns(mutation_mode)

    for i in range(len(rules_list)):
        
        # Exclude rules with this kind of pattern because txl won't parse it
        exclusion_found = False
        for exclusion_pattern in exclusion_patterns:
            exclusion_match = re.findall(exclusion_pattern, rules_list[i])
            if exclusion_match:
                print(f'Rule {i}: Exclusion')
                print(exclusion_match)
                exclusion_found = True
                break
        if exclusion_found:
            continue

        # Find matches for pattern A and add them to eligible list
        for pattern in patterns_A:
            #print(pattern)
            matches = re.findall(pattern, rules_list[i])
            if matches:
                for match in matches:
                    print(f'Rule {i}A: ', match)
                eligible_rules_A.append(i)
                break

        # Find matches for pattern B and add them to eligible list
        for pattern in patterns_B:
            #print(pattern)
            matches = re.findall(pattern, rules_list[i])
            if matches:
                for match in matches:
                    print(f'Rule {i}B: ', match)
                eligible_rules_B.append(i)
                break

    print('\nRule_A eligible indices: ', eligible_rules_A)
    print('Rule_B eligible indices: ', eligible_rules_B)
    
    return eligible_rules_A, eligible_rules_B

def get_rule_patterns(mutation_mode):
    # Create pattern lists to be returned: 
    # Patterns for rule_A, rule_B, and patterns that txl will not parse, and so must be excluded
    patterns_A = []
    patterns_B = []
    exclusion_patterns = []

    # Create list of different formats of action commands
    commands = ['sendCommand', 'postUpdate']
    command_patterns = '(' + '|'.join(commands) + ')'

    # Create list of different formats of action values
    values = ['ON', 'OFF', 'OPEN', 'CLOSED']
    value_patterns = '(' + '|'.join(values) + ')'

    # Create regex patterns
    # eg. when\n TRIGGER\n then\n
    trigger_pattern_general = r'when\n(\t| +)(.+)\nthen\n'

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

    elif mutation_mode == 'STC-A' or mutation_mode == 'WTC-A':
        patterns_A.append(trigger_pattern_general)

        patterns_B.append(action_method_general)
        patterns_B.append(action_function_general)

    elif mutation_mode == 'STC-T' or mutation_mode == 'WTC-T':
        patterns_A.append(action_method_general)
        patterns_A.append(action_function_general)

        patterns_B.append(trigger_pattern_general)
    elif mutation_mode == 'WCC':
        patterns_A.append(action_method_general)
        patterns_A.append(action_function_general)

        patterns_B.append(condition_action)

    # eg. GroupIrrigationTimes.members.findFirst[t | ... ]
    exclusion_patterns.append(r'.members')

    return patterns_A, patterns_B, exclusion_patterns


######
# Main

rules_file = 'rulesets/demo.rules'
rules = get_rules(rules_file)

# Parse rules file
rules_list = separate_rules(rules)

# Specify which type of mutation is being performed
mutation_mode = 'SAC'

# Select 2 rules to mutate
rule_A, rule_B = choose_rules(rules_list, mutation_mode)
rule_A, rule_B = 4, 3 # Testing

# Perform the mutation
mutated_rules = mutate_rules(rules_list, rule_A, rule_B, mutation_mode)

rules_list[rule_A] = mutated_rules[0]
rules_list[rule_B] = mutated_rules[1]


print(mutated_rules[0], '\n')
print(mutated_rules[1])