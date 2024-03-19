import re
from pymut.utilities import data_processors as dp

# STC_A: mutate the ACTION of the SECOND rule
# such that the TRIGGER of the FIRST rule is triggered

def mutate(rule_A, rule_B):
    trigger_A = get_trigger(rule_A)
    mutated_B = mutate_action(trigger_A, rule_B)
    return [rule_A, mutated_B]

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
            break
    return trigger

def mutate_action(trigger_A, rule_B):
    replacement_patterns = {}

    if (trigger_A['command'] == 'received update'
          and trigger_A['value']):
        replacement_patterns['method'] = (trigger_A['item']
                                            + '.postUpdate('
                                            + trigger_A['value'] 
                                            + ')'
            )
        replacement_patterns['function'] = ('postUpdate(' 
                                            + trigger_A['item'] 
                                            + ', ' 
                                            + trigger_A['value'] 
                                            + ')'
            )
    elif (trigger_A['command'] == 'received command'
          or (trigger_A['command'] == 'changed to')
          and trigger_A['value']):
        replacement_patterns['method'] = (trigger_A['item']
                                            + '.sendCommand('
                                            + trigger_A['value'] 
                                            + ')'
            )
        replacement_patterns['function'] = ('sendCommand(' 
                                            + trigger_A['item'] 
                                            + ', ' 
                                            + trigger_A['value'] 
                                            + ')'
            )
    elif (trigger_A['command'] == 'received update'
          and not trigger_A['value']):
        replacement_patterns['method'] = (trigger_A['item']
                                            + '.postUpdate(ON)'
            )
        replacement_patterns['function'] = ('postUpdate(' 
                                            + trigger_A['item'] 
                                            + ', ON)'
            )
    elif (trigger_A['command'] == ('received command' or 'changed to')
          and not trigger_A['value']):
        replacement_patterns['method'] = (trigger_A['item']
                                            + '.sendCommand(ON)'
            )
        replacement_patterns['function'] = ('sendCommand(' 
                                            + trigger_A['item'] 
                                            + ', ON)'
            )

    action_patterns = dp.get_general_action_patterns()

    for pattern in action_patterns:
        print(action_patterns[pattern])
        mutated_B = re.sub(action_patterns[pattern], replacement_patterns[pattern], rule_B, count=0, flags=0)

        if rule_B != mutated_B:
            break

    return mutated_B