import re
from pymut.utilities import data_processors as dp

# STC_T: mutate the TRIGGER of the SECOND rule
# such that the ACTION of the FIRST rule triggers it
def mutate(rule_A, rule_B):
    action_A = dp.get_action_data(rule_A)
    print(action_A)
    rule_B = mutate_trigger(action_A, rule_B)
    return [rule_A, rule_B]

def mutate_trigger(action_A, rule_B):
    trigger_pattern = r'when\n(\t|( *))(.+)\nthen\n'
    if action_A['command'] == 'postUpdate':
        replace_pattern = (r'when\n\tItem '
                        + action_A['item'] + ' received update '
                        + action_A['value'] + '\nthen\n'
        )
    elif action_A['command'] == 'sendCommand':
        replace_pattern = (r'when\n\tItem '
                        + action_A['item'] + ' received command '
                        + action_A['value'] + '\nthen\n'
        )
    print(rule_B)
    mutated_B = re.sub(trigger_pattern, replace_pattern, rule_B, count=0, flags=0)
    print(mutated_B)
    return mutated_B