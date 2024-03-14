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
    with open('mutation.rules', 'w') as file:
        file.write(rules_list[rule_A] + '\n\n' + rules_list[rule_B])
    
    mutated_rules = str(subprocess.run(['txl', 'mutation.rules', mutation_mode], stdout=subprocess.PIPE))
    mutated_rules = separate_rules(mutated_rules.replace('\\n', '\n').replace('\\r', '\r'))
    return mutated_rules


def determine_first_rule_eligibility(rules_list):
    eligible_rules_indices = []

    # Create list of different formats of action commands
    commands = ['sendCommand', 'postUpdate']
    command_patterns = '|'.join(commands)

    # Create list of different formats of action values
    values = ['ON', 'OFF', 'OPEN', 'CLOSED']
    value_patterns = '|'.join(values)

    # Create exclusion pattern
    foreach_pattern = r'\?.members.forEach\('
    
    pattern = command_patterns + r'\(([^)]+),' + value_patterns + r'\)'
    print(pattern)

    for i in range(len(rules_list)):
        
        # Exclude rules with this kind of pattern because txl won't parse it
        exclusion_match = re.findall(foreach_pattern, rules_list[i])
        if exclusion_match:
            print(f'Rule {i+1}: Exclusion')
            continue

        # Find matches and add them to eligible list
        matches = re.findall(pattern, rules_list[i])
        if matches:
            print(f'Rule {i+1}: ', matches)
            eligible_rules_indices.append(i)

    print('Rule_A indices: ', eligible_rules_indices)
    return eligible_rules_indices


def determine_second_rule_eligibility(rules_list):
    eligible_rules_indices = []

    # Create exclusion pattern
    foreach_pattern = r'\?.members.forEach\('

    for i in range(len(rules_list)):
        # Exclude rules with this kind of pattern because txl won't parse it
        exclusion_match = re.findall(foreach_pattern, rules_list[i])
        if not exclusion_match:
            eligible_rules_indices.append(i)
            
    # in a rule with multiple actions, just select the first one?
    # how to make sure that if there are conditions, that the condition that applies to the mutated action is mutated
    print('Rule_B indices: ', eligible_rules_indices)
    return eligible_rules_indices

######
# Main

rules_file = 'IoTB/demo.rules'
rules = get_rules(rules_file)

rules_list = separate_rules(rules)

# Determine eligible rules that function with txl mutator
eligible_rule_A = determine_first_rule_eligibility(rules_list)
eligible_rule_B = determine_second_rule_eligibility(rules_list)

# From eligible rules, select which 2 rules to mutate
rule_A = random.choice(eligible_rule_A)
rule_B = random.choice(eligible_rule_B)

# Specify which type of mutation is being performed
mutation_mode = 'SAC.txl'

mutated_rules = mutate_rules(rules_list, rule_A, rule_B, mutation_mode)

rules_list[rule_A] = mutated_rules[0]
rules_list[rule_B] = mutated_rules[1]


print(mutated_rules[0], '\n')
print(mutated_rules[1])