import os
import requests
from urllib.parse import urlparse
import argparse
import paramiko
from scp import SCPClient

def create_ssh_client(host, port, username, password):
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(host, port=port, username=username, password=password)
    return ssh

def send_file_via_scp(local_path, remote_path, host, port=22, username='user', password='pass'):
    ssh = create_ssh_client(host, port, username, password)
    with SCPClient(ssh.get_transport()) as scp:
        scp.put(local_path, remote_path)
    ssh.close()

def download_mp3(url, filename, output_dir='.', timeout=10):
    try:
        # 确保输出目录存在
        os.makedirs(output_dir, exist_ok=True)
        
        output_path = os.path.join(output_dir, filename)
        
        # 发送HTTP请求
        print(f'开始下载: {url}')
        response = requests.get(url, timeout=timeout, stream=True)
        response.raise_for_status()  # 检查请求是否成功
        
        # 获取文件大小（如果服务器提供）
        file_size = int(response.headers.get('content-length', 0))
        if file_size:
            print(f'文件大小: {file_size / (1024 * 1024):.2f} MB')
        
        # 下载文件
        with open(output_path, 'wb') as f:
            downloaded = 0
            for chunk in response.iter_content(chunk_size=8192):
                if chunk:
                    f.write(chunk)
                    downloaded += len(chunk)
                    # 显示下载进度
                    if file_size:
                        progress = downloaded / file_size * 100
                        print(f'\r下载进度: {progress:.2f}%', end='')
            if file_size:
                print()  # 换行
        
        print(f'下载完成，文件保存至: {output_path}')
        return output_path
    
    except requests.exceptions.Timeout:
        print(f'下载超时: {url}')
    except requests.exceptions.RequestException as e:
        print(f'下载错误: {e}')
    except Exception as e:
        print(f'发生未知错误: {e}')
    return None

if __name__ == "__main__":  
    while True:
        url = input("请输入MP3文件的URL（或输入'quit'退出）: ")
        if url.lower() == 'quit':
            break
        filename = input("请输入保存的文件名（不带扩展名，默认为'output.mp3'）: ") or 'output.mp3'
        url = f'http://music.163.com/song/media/outer/url?id={url}.mp3'
        output_dir = 'download'  # 默认下载目录
        timeout = 10

        download_mp3(url, f"{filename}.mp3", output_dir, timeout)  

        send_file_via_scp(os.path.join(output_dir, f"{filename}.mp3"), f'~/static/music', 'lancelotshire.me', 22, 'azureuser', '20040403Birthday')