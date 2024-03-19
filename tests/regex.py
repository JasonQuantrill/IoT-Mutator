import re
import os

# Clear terminal
os.system('cls' if os.name == 'nt' else 'clear')

p = []
s= []
# Create list of different formats of action commands
# commands = '(sendCommand|postUpdate)'

# # Create list of different formats of action values
# values = ['ON', 'OFF', 'OPEN', 'CLOSED']
# value_patterns = '|'.join(values)

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



p.append(trigger_pattern_itemvalue)
p.append(trigger_pattern_item)
p.append(trigger_pattern_system)
p.append(trigger_pattern_time)

s.append('''
rule "Irrigation - all valves closed"
when
    Time cron "0 * * ? * *"
then
	
	logInfo(logName, "All irrigation valves closed")
	IrrigationCurrentValve.postUpdate(OFF)

	
	IrrigationSectionRemainingTime.postUpdate(0)
end
''')


for ss in s:
    print(f'String: {ss}')
    for pp in p:
        print(f'Pattern: {pp}')

        matches = re.findall(pp, ss)

        print(f'Matches: {matches}\n')

pass

# working

# Pattern B

# s = s.append(r'IrrigationSectionRemainingTime.postUpdate(0)')
# s.append('IrrigationCurrentValve.sendCommand(IrrigationValveZone1.name)')
# p.append(r'(.+)\.' + '(' + command_patterns + ')' + r'\(' + r'(.+)' + r'\)')

# s.append('sendCommand(Item, IrrigationValveZone1.name)')
# p.append('(' + command_patterns + ')' + r'\(' + r'(.+), *' + r'(.+)\)')

# Pattern A
# s.append('IrrigationCurrentValve.sendCommand(OFF)')
# p.append(r'(.+)\.' + '(' + command_patterns + ')' + r'\((' + value_patterns + r')\)')

#s.append('sendCommand(Item, OPEN)')
#s.append('sendCommand(Item,OPEN)')
#p.append('(' + command_patterns + ')' + r'\(' + r'(.+), *' + r'(' + value_patterns + r')\)')

#s.append('''   when
#                   Item GroupIrrigationValves changed to OFF
#               then)
# Captures entire trigger part
#p.append(r'when\n(\t|( *))(.+)\nthen\n')
# Captures each element of trigger
# trigger_pattern = (r'when\n(\t| +)'
#                    + types + ' (.+) '
#                    + commands + values
#                    + r'\nthen\n'
# )


#s.append('''   when
#                   System started
#               then)
# trigger_pattern_system = (r'when\n(\t| +)'
#                    + types + commands
#                    + r'\nthen\n'
# )