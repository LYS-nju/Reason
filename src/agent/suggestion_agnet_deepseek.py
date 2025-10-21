from llm.call_llm import call_deepseek
from utils import load_rules
class SuggestionAgentR1():
    def __init__(self, source_code, rules):
        self.source_code = source_code
        self.rules = rules

    def reason(self):
        system_prompt = """
        You are an expert in detecting access control vulnerabilities.
        I will provide you with a smart contract and some rules.
        Your task is to learn from the rules and generate useful suggestions for vulnerability detection.
        """

        user_prompt = f"""
        This is smart contract:```{self.source_code}```
        You must carefully learn and understand the rules I provide: {self.rules}
        Each **rule** contains:
            - Name: The rule's name
            - Situation: Relevant code snippet
            - Suggestion: Specific suggestions for detecting access control vulnerabilities in smart contracts.
        Next, follow these steps.
        Step 1: **Learn From Rules**: Carefully learn and understand each rule.
        Step 2: **Analyze and Match**: Analyze the source code and identify code snippets that match any of the rules.
        Step 3: **Generate Suggestions**: Produce specific and practical suggestions to improve access control vulnerability detection.
        """

        assistant_content = """
        You must strictly follow the output format and do not include any other information.
        Generate Suggestions in the following structured format:
        [Suggestions]:
        {XXX}
        If no optimization, output:
        [Suggestions]:
        -No Suggestions-
        """

        msg = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt},
            {"role": "assistant", "content": assistant_content},
        ]

        result = ""
        reasoning,content = call_deepseek(msg)
        # result += "======Reasoning======\n"
        # result += reasoning
        # result += "\n======Content======\n"
        result += content
        # print(msg)
        return result
