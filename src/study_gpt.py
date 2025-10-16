import openai
import os
from llm.call_llm import call_gpt
import config
from utils import read_sol_file
import re


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
    result += f"\ntemperature: {config.temperature}"
    result += f"\ntop_p: {config.top_p}"

    print(result)

if __name__ == "__main__":
    solidity_source_code = read_sol_file()
    if solidity_source_code:
        reason(solidity_source_code)