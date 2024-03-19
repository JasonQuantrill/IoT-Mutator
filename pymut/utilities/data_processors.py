import re

def get_specific_action_patterns():
    # Create list of different formats of action commands
    commands = '(sendCommand|postUpdate)'

    # Create list of different formats of action values
    values = '(ON|OFF|OPEN|CLOSED)'

    action_patterns = {}
    # eg. Item.postUpdate(OFF)
    action_method = (r'(.+)\.' + commands 
                      + r'\(' + values + '\)'
                      )
    # eg. postUpdate(Item, OFF)   
    action_function = (commands + r'\(' 
                      + r'(.+), *' 
                      + values + r'\)'
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
    action_method = (r'(.+)\.' + commands 
                      + r'\((.+)\)'
                      )
    # eg. postUpdate(Item, OFF)   
    action_function = (commands + r'\(' 
                      + r'(.+), *(.+)\)'
                      )
    
    action_patterns['method'] = action_method
    action_patterns['function'] = action_function
    
    return action_patterns

def get_action_data(rule_A):
    action = {'item': '',
              'command': '',
              'value': ''
              }
    
    patterns_A = get_specific_action_patterns()

    # Find matches for pattern A and add them to eligible list
    for pattern in patterns_A:
        #print(pattern)
        matches = re.findall(patterns_A[pattern], rule_A)
        if matches:
            action['item'] = matches[0][0].strip()
            action['command'] = matches[0][1]
            action['value'] = matches[0][2]
            break

    return action

# just need to make sure that the same item is being acted on with an opposite value
# have action patterns. So replace one of those, then break.
def mutate_actionB_with_actionA(action_A, rule_B):
    action_patterns = get_general_action_patterns()
    

    for pattern in action_patterns:
        print(action_patterns[pattern])
        matches = re.findall(action_patterns[pattern], rule_B)
        print(matches)
        if matches:
            if pattern == 'method':
                replace_pattern = (action_A['item']
                                            + '.' 
                                            + matches[0][1]
                                            + '('
                                            + opposite(action_A['value']) 
                                            + ')'
                )
                mutated_B = re.sub(action_patterns[pattern], replace_pattern, rule_B, count=0, flags=0)
                return mutated_B
            elif pattern == 'function':
                replace_pattern = (action_A['item']
                                            + '.' 
                                            + matches[0][1]
                                            + '('
                                            + opposite(action_A['value']) 
                                            + ')'
                )
                mutated_B = re.sub(action_patterns[pattern], replace_pattern, rule_B, count=0, flags=0)
                return mutated_B
        

def opposite(value):
    if value == 'ON': return 'OFF'
    if value == 'OFF': return 'ON'
    if value == 'OPEN': return 'CLOSED'
    if value == 'CLOSED': return 'OPEN'