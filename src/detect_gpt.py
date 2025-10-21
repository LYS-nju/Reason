import os
from llm.call_llm import call_gpt
import config
from utils import read_sol_file
import re
import time


def reason(solidity_source_code):
    system_prompt = """
    You are a smart contract security expert specialized in access control vulnerabilities. 
    Analyze the following Solidity source code and report any access control vulnerabilities.
    **Focus exclusively** on access control vulnerabilities.
    """

    source_code = solidity_source_code

    user_prompt = f"""
    This is the Solidity source code: ```{source_code}```
    """

    assistant_content = """
    Ouput your reasoning process step by step
    Finally, list the access control vulnerabilities you detected in the following format:  
    {Function: XXX, Vulnerability Description: XXX}
    If no access control vulnerabilities are detected, output:  
    {No Access Control Vulnerabilities}
    """

    msg = [
        {"role": "system", "content": system_prompt},
        {"role": "user", "content": user_prompt},
        {"role": "assistant", "content": assistant_content},
    ]

    result = ""
    result += call_gpt(msg)
    # Redundant information
    # result += f"\ntemperature: {config.temperature}"
    # result += f"\ntop_p: {config.top_p}"

    print(result)

if __name__ == "__main__":
    start_time = time.time()
    config.total_token = 0
    solidity_source_code = read_sol_file()
    if solidity_source_code:
        reason(solidity_source_code)

    end_time = time.time()
    print(f"\ntemperature: {config.temperature}")
    print(f"top_p: {config.top_p}")
    print(f"total time: {end_time - start_time}")
    print(f"total token: {config.total_token}")
    print("==========End===========")