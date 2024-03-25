import os

# Clear terminal
os.system('cls' if os.name == 'nt' else 'clear')

def get_rules():
    # Open the .rules file in read mode
    with open(f'Rulesets/OwnTracks.rules', 'r') as file:
        # Read the contents of the file
        file_contents = file.read()
    return file_contents

print('CWD: ', os.getcwd() )
rules = get_rules()

# Write the original rules to file
with open('copied.rules', 'w') as file:
    file.write(rules)
