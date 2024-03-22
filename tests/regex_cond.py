import re
import os

# Clear terminal
os.system('cls' if os.name == 'nt' else 'clear')

p = []
s= []

action = r'IrrigationCurrentValve\.postUpdate\(OFF\)'
p.append(
        r'((\t| +)if \((.+)(\n| +)\{\n' +
        '(\t+| +' + action + '))'
)


s.append('''
rule "Irrigation - update timer"
when
        Item GroupIrrigationValves changed to OFF      
then
        if (IrrigationSectionRemainingTime.state as Number > 0) {
            IrrigationCurrentValve.postUpdate(OFF)
    }
end
         ''')


for ss in s:
    print(f'String: {ss}')
    for pp in p:
        print(f'Pattern: {pp}')

        matches = re.findall(pp, ss)

        print(f'Matches: {matches}\n')