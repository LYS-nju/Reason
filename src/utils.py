import os
import yaml
import config

# load rules
def load_rules(rule_path=config.rules_path):
    with open(rule_path, "r") as f:
        return yaml.safe_load(f)


# read solidity
def read_sol_file(file_path=config.SOL_FILE_PATH):
    if not os.path.exists(file_path):
        print(f"Error: The file {file_path} does not exist.")
        return None
    
    try:
        with open(file_path, 'r') as file:
            content = file.read()
            return content
    except Exception as e:
        return None
    
# read cot
def read_cot(cot_file=config.cot_path):
    if not os.path.exists(cot_file):
        return None
    try:
        with open(cot_file, 'r') as file:
            cot = file.read()
            return cot
    except Exception as e:
        return None