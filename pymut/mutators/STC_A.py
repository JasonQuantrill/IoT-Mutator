import re
from pymut.utilities import data_processors as dp

# STC_A: mutate the ACTION of the SECOND rule
# such that the TRIGGER of the FIRST rule is triggered

def mutate(rule_A, rule_B):
    trigger_A = dp.get_trigger_data(rule_A)
    mutated_B = dp.mutate_actionB_with_TriggerA(trigger_A, rule_B)
    mutated_A, mutated_B = dp.remove_conditions(rule_A, mutated_B)
    return [rule_A, mutated_B]



