import re
from pymut.utilities import data_processors as dp

def mutate(rule_A, rule_B):
    action_A = dp.get_action_data(rule_A)
    mutated_B = dp.mutate_actionB_with_actionA(action_A, rule_B)