import re
import os

# Clear terminal
os.system('cls' if os.name == 'nt' else 'clear')

# Create list of different formats of action commands
commands = ['sendCommand', 'postUpdate']
command_patterns = '|'.join(commands)

# Create list of different formats of action values
values = ['ON', 'OFF', 'OPEN', 'CLOSED']
value_patterns = '|'.join(values)

s = []

s.append('IrrigationSectionRemainingTime.postUpdate(0)')
s.append('IrrigationCurrentValve.sendCommand(IrrigationValveZone1.name)')
s.append('sendCommand(Item, IrrigationValveZone1.name)')
s.append('IrrigationCurrentValve.sendCommand(OFF)')
s.append('sendCommand(Item, OPEN)')
s.append('sendCommand(Item,ON)')

p = []
#p.append(r'(.+)\.' + '(' + command_patterns + ')' + r'\((' + value_patterns + r')\)')
p.append('(' + command_patterns + ')' + r'\(' + r'(.+), *' + r'(' + value_patterns + r')\)')


#p.append(r'\(([^)]+).' + command_patterns + r'\(' + value_patterns + r'\)')

for ss in s:
    for pp in p:
        print(f'String: {ss}')
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

