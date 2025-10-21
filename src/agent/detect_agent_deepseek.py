from llm.call_llm import call_deepseek
class DetectAgentR1():
    def __init__(self, source_code, suggestions):
        self.source_code = source_code
        self.suggestions = suggestions

    def reason(self):
        system_prompt = """
        You are an expert in detecting vulnerabilities in smart contracts.
        Your task is to use provided suggestions to identify access control vulnerabilities in smart contracts.
        **Focus exclusively** on access control vulnerabilities.
        """

        user_prompt = f"""
        This is smart contract:```{self.source_code}```
        This is the suggestions: {self.suggestions}
        Step 1: **Understand Suggestions**: Carefully review the provided suggestions.
        Step 2: **Detect**: Based on the source code and suggestions, identify access control vulnerabilities.
        Step 3: **Self-evaluate**: Carefully review your report to ensure all suggestions have been followed and no errors have been introduced.
        """

        assistant_content = """
        You must strictly follow the output format and do not include any other information.
        - Do not include “general” or “various” in vulnerability reports.
        Finally, you must strictly Output the vulnerabilities you detected, in the following format:
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
        reasoning,content = call_deepseek(msg)
        result += "======Reasoning======\n"
        result += reasoning
        result += "\n======Content======\n"
        result += content
        return result
