DATASET_PATH = "datasets/clean_datasets/smartbugs_curated/"

rules_path = "rules.yaml"
cot_path = "../cot/0x07f7ecb66d788ab01dc93b9b71a88401de7d0f2e.txt"

gpt_url = "https://api.chatanywhere.tech/v1"  # gpt url
gpt_key = "" # GPT api
# gpt_model = "gpt-4o-mini"
gpt_model = "gpt-4o"
# gpt_model = "gpt-4"

deepseek_url = "https://api.deepseek.com"
deepseek_key = ""
deepseek_model = "deepseek-reasoner"

temperature = 0
top_p = 0.9
# max_tokens = 1024

SOL_FILE = 'arbitrary_location_write_simple.sol'
SOL_FILE_PATH = DATASET_PATH + SOL_FILE
