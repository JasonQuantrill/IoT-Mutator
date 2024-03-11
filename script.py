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
    mutated_rules = separate_rules(mutated_rules)
    return mutated_rules


rules_file = 'IoTB/demo.rules'
rules = get_rules(rules_file)

rules_list = separate_rules(rules)

# Specify which 2 rules to mutate
rule_A = 0
rule_B = 1

# Specify which type of mutation is being performed
mutation_mode = 'SAC.txl'

mutated_rules = mutate_rules(rules_list, rule_A, rule_B, mutation_mode)
print(len(mutated_rules))