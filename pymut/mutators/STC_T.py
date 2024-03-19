import re

# STC_T: mutate the TRIGGER of the SECOND rule
# such that the ACTION of the FIRST rule triggers it
def mutate(rule_A, rule_B):
    action_A = get_action(rule_A)
    print(action_A)
    rule_B = mutate_trigger(action_A, rule_B)
    return [rule_A, rule_B]

def get_action(rule_A):
    action = {'item': '',
              'command': '',
              'value': ''
              }
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

    # Find matches for pattern A and add them to eligible list
    for pattern in patterns_A:
        #print(pattern)
        matches = re.findall(pattern, rule_A)
        if matches:
            action['item'] = matches[0][0].strip()
            action['command'] = matches[0][1]
            action['value'] = matches[0][2]
            break

    return action

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