from llm.call_llm import call_deepseek
from utils import read_sol_file,load_rules
from agent.suggestion_agnet_deepseek import SuggestionAgentR1
from agent.detect_agent_deepseek import DetectAgentR1
import config
import time

if __name__ == "__main__":
    start_time = time.time()
    config.total_token = 0
    solidity_source_code = read_sol_file()
    if solidity_source_code:
        rules = load_rules()
        suggestion_agent = SuggestionAgentR1(solidity_source_code, rules)
        suggestions = suggestion_agent.reason()
        detect_agent = DetectAgentR1(solidity_source_code, suggestions)
        vulnerability_reports = detect_agent.reason()

        end_time = time.time()
        print(vulnerability_reports)
        print(f"temperature: {config.temperature}")
        print(f"top_p: {config.top_p}")
        print(f"total time: {end_time - start_time}")
        print(f"total token: {config.total_token}")
    
    print("==========End===========")        
