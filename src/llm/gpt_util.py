# 这个文件存放了GPT的通用函数
import config
import re

from openai import OpenAI
from utils import append_to_file

def call_chatgpt(messages) -> list:
    client = OpenAI(
        base_url=config.gpt_url,
        api_key=config.gpt_key,
    )

    res = client.chat.completions.create(model=config.gpt_model, messages=messages,
                                         temperature=config.temperature,
                                         top_p=config.top_p,
                                         n=1, stop=None)

    return res.choices[0].message.content

def write_gpt_log(vulnerabilities_info, contract):
    # 先将GPT的信息输入到info文件里
    # 这里面有很多信息
    append_to_file(config.result_dir + config.SOL_FILE + "/" + contract.name + "/info",
                   vulnerabilities_info)

    # 定义正则表达式，忽略大小写，匹配形如 Output:{Function:XXX,Vulnerabilities:Yes 的行
    pattern_report = r'Result\s*:\s*\{\s*Function\s*:\s*\w+\s*,\s*Vulnerabilities\s*:\s*Yes\b.*?\}'
    match_report = re.findall(pattern_report, vulnerabilities_info, re.IGNORECASE)

    # 漏洞报告
    vulnerabilities_report = "\n".join(match_report) if match_report else None

    # 代表存在漏洞
    if vulnerabilities_report:
        append_to_file(config.result_dir + config.SOL_FILE + "/" + contract.name + "/report",
                       vulnerabilities_report)
