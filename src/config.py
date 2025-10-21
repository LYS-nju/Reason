DATASET_PATH = "datasets/clean_datasets/CVE/"
# DATASET_PATH = "datasets/clean_datasets/smartbugs_curated/"
# DATASET_PATH = "datasets/clean_datasets/Code4rena/"

rules_path = "rules.yaml"

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

total_token = 0

SOL_FILE = 'CVE-2018-10666.sol'
SOL_FILE_PATH = DATASET_PATH + SOL_FILE
