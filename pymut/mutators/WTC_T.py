import re
from pymut.utilities import data_processors as dp

# STC_T: mutate the TRIGGER of the SECOND rule
# such that the ACTION of the FIRST rule triggers it
def mutate(rule_A, rule_B):
    action_A = dp.get_action_data(rule_A)
    rule_B = dp.mutate_triggerB_with_actionA(action_A, rule_B)
    mutated_B = dp.compatible_conditions(rule_A, mutated_B)
    return [rule_A, rule_B]