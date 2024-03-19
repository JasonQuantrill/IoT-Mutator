import re

# STC_A: mutate the ACTION of the SECOND rule
# such that the TRIGGER of the FIRST rule is triggered

def mutate(rule_A, rule_B):
    trigger_A = get_trigger(rule_A)
    print(trigger_A)
    rule_B = mutate_action(trigger_A, rule_B)
    return [rule_A, rule_B]

def get_trigger(rule_A):
    trigger = {'type': '',
            'item': '',
            'command': '',
            'value': ''
            }
    
    types = '(Item|Time|System)'
    commands = '(received update |received command |changed|changed to | started| cron )'
    values = '(ON|OFF|OPEN|CLOSED)'

    trigger_pattern_itemvalue = (r'when\n(\t| +)'
                    + types + ' (.+) '
                    + commands + values
                    + r'\nthen\n'
    )

    trigger_pattern_item = (r'when\n(\t| +)'
                    + types + ' (.+) '
                    + commands
                    + r'\nthen\n'
    )

    trigger_pattern_system = (r'when\n(\t| +)'
                    + types + commands
                    + r'\nthen\n'
    )

    trigger_pattern_time = (r'when\n(\t| +)'
                    + types + commands + r'\"(.+)\"'
                    + r'\nthen\n'
    )
    
    trigger_patterns = []
    trigger_patterns.append(trigger_pattern_item)
    trigger_patterns.append(trigger_pattern_itemvalue)
    trigger_patterns.append(trigger_pattern_system)
    trigger_patterns.append(trigger_pattern_time)

    for pattern in trigger_patterns:
        #print(pattern)
        matches = re.findall(pattern, rule_A)
        if matches:
            # item trigger pattern
            if matches[0][1] == 'Item' and len(matches[0]) == 4:
                trigger['type'] = matches[0][1].strip()
                trigger['item'] = matches[0][2].strip()
                trigger['command'] = matches[0][3].strip()
            # item-value trigger pattern
            elif matches[0][1] == 'Item' and len(matches[0]) == 5:
                trigger['type'] = matches[0][1].strip()
                trigger['item'] = matches[0][2].strip()
                trigger['command'] = matches[0][3].strip()
                trigger['value'] = matches[0][4].strip()
            # system trigger pattern
            elif matches[0][1] == 'System':
                trigger['type'] = matches[0][1].strip()
                trigger['command'] = matches[0][2].strip()
            # time trigger pattern
            elif matches[0][1] == 'Time':
                trigger['type'] = matches[0][1].strip()
                trigger['command'] = matches[0][2].strip()
                trigger['value'] = matches[0][3]
            print(trigger)
            break
    return trigger

def mutate_action(trigger_A, rule_B):
    action_pattern = r'when\n(\t|( *))(.+)\nthen\n'
    
    if trigger_A['command'] == 'postUpdate':
        replace_pattern = (r'when\n\tItem '
                        + action_A['item'] + ' received update '
                        + action_A['value'] + '\nthen\n'
        )
    elif trigger_A['command'] == 'sendCommand':
        replace_pattern = (r'when\n\tItem '
                        + action_A['item'] + ' received command '
                        + action_A['value'] + '\nthen\n'
        )
    print(rule_B)
    mutated_B = re.sub(action_pattern, replace_pattern, rule_B, count=0, flags=0)
    print(mutated_B)
    return mutated_B