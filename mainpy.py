import os
import re
import random
import subprocess
from Mutators.pymut import STC_A, STC_T
from Mutators.pymut.utilities import utils

# Clear terminal
os.system('cls' if os.name == 'nt' else 'clear')


def get_rules(rules_file):
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

def mutate_rules_py(rules_list, rule_A, rule_B, mutation_mode):
    with open('mutators/pymut/output/originalpy.rules', 'w') as file:
        file.write(rules_list[rule_A] + '\n\n' + rules_list[rule_B])
    
    mutated_rules = STC_T.mutate(rules_list[rule_A], rules_list[rule_B])
    
    with open('mutators/pymut/output/mutatedpy.rules', 'w') as file:
        file.write(mutated_rules[0] + '\n\n' + mutated_rules[1])
    
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

    patterns_A = []
    # eg. Item.postUpdate(OFF)
    patterns_A.append(r'(.+)\.' + '(' + command_patterns + ')' + r'\((' + value_patterns + r')\)')
    # eg. postUpdate(Item, OFF)   
    patterns_A.append('(' + command_patterns + ')' + r'\(' + r'(.+), *' + r'(' + value_patterns + r')\)')


    patterns_B = []
    # eg. Item.postUpdate(Any.Value)
    patterns_B.append(r'(.+)\.' + '(' + command_patterns + ')' + r'\(' + r'(.+)' + r'\)')
    # eg. postUpdate(Item, Any.Value)
    patterns_B.append('(' + command_patterns + ')' + r'\(' + r'(.+) *,' + r'(.+)\)')

    # Group of patterns that txl will not parse, and so must be excluded
    exclusion_patterns = []
    # eg. GroupIrrigationTimes.members.findFirst[t | ... ]
    exclusion_patterns.append(r'.members')

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

def choose_rules(rules_list):
    # Determine eligible rules that function with txl mutator
    eligible_rule_A, eligible_rule_B = determine_rule_eligibility(rules_list)

    # From eligible rules, select the indices of 2 rules to mutate
    rule_A = random.choice(eligible_rule_A)

    eligible_rule_B.remove(rule_A)
    rule_B = random.choice(eligible_rule_B)
    
    print(f'\nSelected rules {rule_A} and {rule_B}\n')

    return rule_A, rule_B


def main():
    rules_file = 'rulesets/irrigation4.rules'
    rules = get_rules(rules_file)

    # Parse rules file
    rules_list = separate_rules(rules)

    # Select 2 rules to mutate
    rule_A, rule_B = choose_rules(rules_list)
    rule_A, rule_B = 0, 1 # Testing

    # Specify which type of mutation is being performed
    mutation_mode = 'STC-A'

    mutated_rules = mutate_rules_py(rules_list, rule_A, rule_B, mutation_mode)

    rules_list[rule_A] = mutated_rules[0]
    rules_list[rule_B] = mutated_rules[1]


    print(mutated_rules[0], '\n')
    print(mutated_rules[1])

if __name__ == "__main__":
    main()


