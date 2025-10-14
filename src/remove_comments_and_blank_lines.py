import re
import argparse
import os


def remove_comments_and_empty_lines(sol_code):
    without_comments = re.sub(r'\/\/.*|\/\*[\s\S]*?\*\/', '', sol_code)

    cleaned_code = '\n'.join([line for line in without_comments.splitlines() if line.strip()])

    return cleaned_code


def process_files(input_dir, output_dir):
    # 遍历输入目录下所有的 .sol 文件
    for root, dirs, files in os.walk(input_dir):
        for file in files:
            if file.endswith(".sol"):
                input_file_path = os.path.join(root, file)

                # 计算输出文件路径，保持目录结构
                relative_path = os.path.relpath(input_file_path, input_dir)
                output_file_path = os.path.join(output_dir, relative_path)

                # 确保输出文件夹存在
                output_file_dir = os.path.dirname(output_file_path)
                if not os.path.exists(output_file_dir):
                    os.makedirs(output_file_dir)

                # 读取Solidity文件，去除注释和空行
                with open(input_file_path, 'r', encoding='utf-8') as file:
                    solidity_code = file.read()

                cleaned_solidity_code = remove_comments_and_empty_lines(solidity_code)

                # 写入处理后的文件
                with open(output_file_path, 'w', encoding='utf-8') as cleaned_file:
                    cleaned_file.write(cleaned_solidity_code)

                print(f"处理完毕：{input_file_path} -> {output_file_path}")


if __name__ == "__main__":
    # 设置命令行参数
    parser = argparse.ArgumentParser(description='Remove comments and empty lines from all .sol files in a directory.')
    parser.add_argument('input_dir', type=str, help='Path to the input directory containing .sol files.')
    parser.add_argument('output_dir', type=str, help='Path to the output directory to save cleaned .sol files.')

    args = parser.parse_args()

    # 检查输入目录是否存在
    if not os.path.isdir(args.input_dir):
        print(f"输入目录 {args.input_dir} 不存在。")
    else:
        # 处理所有文件
        process_files(args.input_dir, args.output_dir)
