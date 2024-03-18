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
    with open('original.rules', 'w') as file:
        file.write(rules_list[rule_A] + '\n\n' + rules_list[rule_B])
    
    mutated_rules = str(subprocess.run(['txl', 'original.rules', f'Mutators/{mutation_mode}'], stdout=subprocess.PIPE))
    mutated_rules = separate_rules(mutated_rules.replace('\\n', '\n').replace('\\r', '\r'))
    return mutated_rules

def determine_rule_eligibility(rules_list):
    eligible_rules_A = []
    eligible_rules_B = []

    # Create list of different formats of action commands
    commands = ['sendCommand', 'postUpdate']
    command_patterns = '|'.join(commands)

    # Create list of different formats of action values
    values = ['ON', 'OFF', 'OPEN', 'CLOSED']
    value_patterns = '|'.join(values)

    # Create exclusion pattern
    foreach_pattern = r'.members'

    patterns_A = []
    patterns_A.append(command_patterns + r'\(([^)]+),' + value_patterns + r'\)')
    patterns_A.append(r'\(([^)]+).' + command_patterns + r'\(' + value_patterns + r'\)')

    patterns_B = []
    patterns_B.append(command_patterns + r'\(([^)]+), ([^)]+)\)')
    patterns_B.append(r'\(([^)]+).' + command_patterns + r'\(([^)]+)\)')

    for i in range(len(rules_list)):
        
        # Exclude rules with this kind of pattern because txl won't parse it
        exclusion_match = re.findall(foreach_pattern, rules_list[i])
        if exclusion_match:
            print(f'Rule {i}: Exclusion')
            continue

        # Find matches for pattern A and add them to eligible list
        for pattern in patterns_A:
            #print(pattern)
            matches = re.findall(pattern, rules_list[i])
            if matches:
                print(f'Rule {i}: ', matches)
                eligible_rules_A.append(i)
                break

        # Find matches for pattern B and add them to eligible list
        for pattern in patterns_B:
            #print(pattern)
            matches = re.findall(pattern, rules_list[i])
            if matches:
                print(f'Rule {i}: ', matches)
                eligible_rules_B.append(i)
                break

    print('\nRule_A eligible indices: ', eligible_rules_A)
    print('Rule_B eligible indices: ', eligible_rules_B)
    
    return eligible_rules_A, eligible_rules_B

def choose_rules(rules_list):
    # Determine eligible rules that function with txl mutator
    eligible_rule_A, eligible_rule_B = determine_rule_eligibility(rules_list)

    # From eligible rules, select the indices of 2 rules to mutate
    rule_A = random.choice(eligible_rule_A)
    rule_B = random.choice(eligible_rule_B)

    print(f'\nSelected rules {rule_A} and {rule_B}\n')

    return rule_A, rule_B



######
# Main

rules_file = 'rulesets/irrigation.rules'
rules = get_rules(rules_file)

# Parse rules file
rules_list = separate_rules(rules)

# Select 2 rules to mutate
rule_A, rule_B = choose_rules(rules_list)

# Specify which type of mutation is being performed
mutation_mode = 'SAC.txl'

mutated_rules = mutate_rules(rules_list, rule_A, rule_B, mutation_mode)

rules_list[rule_A] = mutated_rules[0]
rules_list[rule_B] = mutated_rules[1]


print(mutated_rules[0], '\n')
print(mutated_rules[1])