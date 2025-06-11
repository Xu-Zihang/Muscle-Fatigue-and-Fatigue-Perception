import csv
import random

# Define the number of subjects
num_subjects = 27

# Define the experimental groups and their corresponding block numbers
groups = {
    0: [750, 750, 750, 750],
    1: [675, 600, 525, 450],
    2: [825, 900, 975, 1050]
}

# List to store all subjects' experimental arrangements
all_arrangements = []

# Generate experimental arrangements for each subject
for subject_id in range(1, num_subjects + 1):
    # Randomly shuffle the order of experimental groups
    group_order = [0, 1, 2]
    random.shuffle(group_order)

    subject_arrangement = [subject_id]
    for group in group_order:
        # Randomly shuffle the order of block numbers within the group
        block_numbers = groups[group].copy()
        random.shuffle(block_numbers)
        subject_arrangement.extend([group] + block_numbers)

    all_arrangements.append(subject_arrangement)

# Define the headers for the CSV file
headers = ['Subject ID']
for i in range(1, 4):
    headers.extend([f'Group {i}', f'Block {i * 4 - 3}', f'Block {i * 4 - 2}', f'Block {i * 4 - 1}', f'Block {i * 4}'])

# Save the experimental arrangements to a CSV file
with open('experimental_arrangement.csv', 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    # Write the headers
    writer.writerow(headers)
    # Write each subject's experimental arrangement
    for arrangement in all_arrangements:
        writer.writerow(arrangement)

print("The experimental arrangement table has been saved to the experimental_arrangement.csv file.")
