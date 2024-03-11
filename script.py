import os
import re
import random

# Clear terminal
os.system('cls' if os.name == 'nt' else 'clear')

def separate_rules():
    # Initialize an empty list to store each rule
    rules_list = []

    # Open the .rules file in read mode
    with open('IoTB/demo.rules', 'r') as file:
        # Read the contents of the file
        file_contents = file.read()

        # # Remove block comments
        # file_contents = re.sub(r'/\*\*.*?\*/', '', file_contents, flags=re.DOTALL)

        # Split the content by 'end' to get individual blocks, assuming each rule ends with 'end'
        rules = file_contents.split('\nend\n')

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

    # Print each rule
    for i, rule in enumerate(rules_list, start=1):
        print('-------------------')
        print(f"Rule {i}:\n{rule}\n---\n")


def mutate_rules(rules_list):
    rule_A = 1
    rule_B = 2
    rules_to_mutate = rules_list[rule_A] + rules_list[rule_B]
    mutated_rules = subprocess.run(['txl', test_case, self.test_prog], stdout=subprocess.PIPE)

    base_folder = os.path.join('C:', os.sep, 'Users', 'jason', 'OneDrive', 'Documents', 'TMU', 'CPS40A', 'IoT-Mutator')
    test_prog = os.path.join(base_folder, 'WAC.txl') 
        
    def test_Base(self):
        test_case = os.path.join(self.base_folder, 'testsuite', 'Base.rules')

        test_result = subprocess.run(['txl', test_case, self.test_prog], stdout=subprocess.PIPE)



rules_list = separate_rules()
mutate_rules(rules_list)