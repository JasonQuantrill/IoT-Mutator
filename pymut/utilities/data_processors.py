import re

def get_specific_action_patterns():
    # Create list of different formats of action commands
    commands = '(sendCommand|postUpdate)'

    # Create list of different formats of action values
    values = '(ON|OFF|OPEN|CLOSED)'

    action_patterns = {}
    # eg. Item.postUpdate(OFF)
    action_method = (r'((.+)\.' + commands 
                      + r'\(' + values + '\))'
                      )
    # eg. postUpdate(Item, OFF)   
    action_function = (r'(' + commands + r'\(' 
                      + r'(.+), *' 
                      + values + r'\))'
                      )
    
    action_patterns['method'] = action_method
    action_patterns['function'] = action_function
    
    return action_patterns

def get_general_action_patterns():
    # Create list of different formats of action commands
    commands = '(sendCommand|postUpdate)'

    # Create list of different formats of action values
    values = '(ON|OFF|OPEN|CLOSED)'

    action_patterns = {}
    # eg. Item.postUpdate(OFF)
    action_method = (r'((.+)\.' + commands 
                      + r'\((.+)\))'
                      )
    # eg. postUpdate(Item, OFF)   
    action_function = (r'(' + commands + r'\(' 
                      + r'(.+), *(.+)\))'
                      )
    
    action_patterns['method'] = action_method
    action_patterns['function'] = action_function
    
    return action_patterns

def get_action_data(rule_A):
    action = {'item': '',
              'command': '',
              'value': '',
              'action': ''
              }
    
    patterns_A = get_specific_action_patterns()

    # Find matches for pattern A and add them to eligible list
    for pattern in patterns_A:
        
        matches = re.findall(patterns_A[pattern], rule_A)
        print('Matches: ', matches)
        if matches:
            action['item'] = matches[0][1]
            action['command'] = matches[0][2]
            action['value'] = matches[0][3]
            action['action'] = matches[0][0]
            break
    return action

def mutate_actionB_with_actionA(action_A, rule_B):
    action_patterns = get_general_action_patterns()
    

    for pattern in action_patterns:
        matches = re.findall(action_patterns[pattern], rule_B)
        if matches:
            if pattern == 'method':
                replace_pattern = (action_A['item']
                                            + '.' 
                                            + matches[0][2]
                                            + '('
                                            + opposite(action_A['value']) 
                                            + ')'
                )
                mutated_B = re.sub(action_patterns[pattern], replace_pattern, rule_B, count=0, flags=0)
                return mutated_B, replace_pattern
            elif pattern == 'function':
                replace_pattern = (action_A['item']
                                            + '.' 
                                            + matches[0][2]
                                            + '('
                                            + opposite(action_A['value']) 
                                            + ')'
                )
                mutated_B = re.sub(action_patterns[pattern], replace_pattern, rule_B, count=0, flags=0)
                return mutated_B, replace_pattern
        
def mutate_actionB_with_TriggerA(trigger_A, rule_B):
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


def opposite(value):
    if value == 'ON': return 'OFF'
    if value == 'OFF': return 'ON'
    if value == 'OPEN': return 'CLOSED'
    if value == 'CLOSED': return 'OPEN'


def get_trigger_data(rule_A):
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

def mutate_triggerB_with_actionA(action_A, rule_B):
    general_trigger_pattern = r'when\n(\t| +)(.+)\nthen\n'
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
    mutated_B = re.sub(general_trigger_pattern, replace_pattern, rule_B, count=0, flags=0)
    print(mutated_B)
    return mutated_B

def compatible_triggers(rule_A, rule_B):
    return rule_B

def identical_triggers(rule_A, rule_B):
    general_trigger_pattern = r'when\n(\t| +)(.+)\nthen\n'
    matches = re.findall(general_trigger_pattern, rule_A)
    print(matches)
    replace_pattern = 'when\n\t' + matches[0][1] + '\nthen\n'
    mutated_B = re.sub(general_trigger_pattern, replace_pattern, rule_B)
    return mutated_B



def compatible_conditions(rule_A, rule_B):
    return rule_B

def remove_conditions(rule_A, action_A, rule_B, action_B):
    condition_patterns_A = []
    condition_patterns_A.append(
        r'((\t| +)if \((.+)(\n| +)\{\n' +
        '(\t+| +' + action_A['action'] + '))'
    )

    print('Action B: ', action_B)
    condition_patterns_B = []
    condition_patterns_B.append(
        r'((\t| +)if \((.+)(\n| +)\{\n' +
        '(\t+| +' + action_B.strip() + '))'
    )

    # Remove the condition that surrounds the mutation action in rule A
    for pattern in condition_patterns_A:
        mutated_A = re.sub(pattern, action_A['action'], rule_A)
    # Remove the condition that surrounds the mutation action in rule B
    for pattern in condition_patterns_B:
        mutated_A = re.sub(pattern, action_A['action'], rule_A)
    return mutated_A, rule_B

def mutate_conditionB_with_actionA(action_A, rule_B):
    return rule_B

