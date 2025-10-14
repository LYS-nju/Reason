import config

from openai import OpenAI

def call_gpt(messages) -> list:

    client = OpenAI(
        base_url=config.gpt_url,
        api_key=config.gpt_key,
    )

    res = client.chat.completions.create(model=config.gpt_model, messages=messages,
                                         temperature=config.temperature,
                                         top_p=config.top_p,
                                         n=1, stop=None)

    return res.choices[0].message.content


def call_r1(messages) -> tuple[str, str]:
    
    client = OpenAI(
        base_url=config.deepseek_url,
        api_key=config.deepseek_key,
    )

    res = client.chat.completions.create(model=config.deepseek_model, messages=messages,stream=False,
                                         temperature=config.temperature,
                                         top_p=config.top_p,
                                         n=1, stop=None)
    return res.choices[0].message.reasoning_content, res.choices[0].message.content