import os
import re
import random
import subprocess
from pymut.mutators import STC_A, STC_T
from pymut.utilities import utils

# Clear terminal
os.system('cls' if os.name == 'nt' else 'clear')

def mutate_rules_py(rules_list, rule_A, rule_B, mutation_mode):
    with open('pymut/output/originalpy.rules', 'w') as file:
        file.write(rules_list[rule_A] + '\n\n' + rules_list[rule_B])
    
    mutated_rules = STC_T.mutate(rules_list[rule_A], rules_list[rule_B])
    
    with open('pymut/output/mutatedpy.rules', 'w') as file:
        file.write(mutated_rules[0] + '\n\n' + mutated_rules[1])
    
    return mutated_rules

def main():
    rules_file = 'rulesets/irrigation4.rules'
    rules = utils.get_rules(rules_file)

    # Parse rules file
    rules_list = utils.separate_rules(rules)

    # Select 2 rules to mutate
    rule_A, rule_B = utils.choose_rules(rules_list)
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


