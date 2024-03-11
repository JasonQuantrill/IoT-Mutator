# Initialize an empty list to store each rule
rules_list = []

# Open the .rules file in read mode
with open('IoTB/demo.rules', 'r') as file:
    # Read the contents of the file
    file_contents = file.read()

    # Split the content by 'end' to get individual blocks, assuming each rule ends with 'end'
    blocks = file_contents.split('end')

    # Process each block to extract the rule (assuming each rule starts with "rule")
    for block in blocks:
        # Trim whitespace
        trimmed_block = block.strip()
        if trimmed_block:
            # Find the index of the first occurrence of "rule" in the block
            rule_start_index = trimmed_block.find("rule")
            # Check if "rule" is found and not at the beginning
            if rule_start_index != -1:
                # Extract the rule starting from "rule" to the end of the block
                rule = trimmed_block[rule_start_index:] + 'end'  # Append 'end' back to the rule
                rules_list.append(rule)

# Print each rule
# for i, rule in enumerate(rules_list, start=1):
#     print(f"Rule {i}:\n{rule}\n---\n")

print(rules_list[2])