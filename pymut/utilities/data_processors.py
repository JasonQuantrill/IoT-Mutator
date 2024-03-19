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


def mutate_actionB_with_actionA(action_A, rule_B):
    patterns_A = get_general_action_patterns()
