import re
from pymut.utilities import data_processors as dp

def mutate(rule_A, rule_B):
    action_A = dp.get_action_data(rule_A)
    mutated_B, mutated_action_B = dp.mutate_actionB_with_actionA(action_A, rule_B)
    mutated_B = dp.identical_triggers(rule_A, mutated_B)
    mutated_A, mutated_B = dp.remove_conditions(rule_A, action_A, mutated_B, mutated_action_B)
    return [rule_A, mutated_B]