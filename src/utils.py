import os
import yaml
import config


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
    