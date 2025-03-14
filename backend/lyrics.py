import base64
import requests
import re

def parse_lrc(lrc_text):
    metadata = {}  # 存储歌曲元数据（歌手、标题等）
    lyrics = []    # 存储歌词，每行是 (时间, 歌词)

    lines = lrc_text.strip().split("\n")  # 按行分割

    for line in lines:
        match = re.match(r"\[(\d+):(\d+(\.\d+)?)\](.*)", line)  # 解析时间戳
        if match:
            minutes = int(match.group(1))
            seconds = float(match.group(2))
            timestamp = minutes * 60 + seconds  # 计算总秒数
            lyrics.append((timestamp, match.group(4).strip()))  # 存储 (时间, 歌词)
        else:
            meta_match = re.match(r"\[(\w+):(.+)\]", line)  # 解析元数据
            if meta_match:
                metadata[meta_match.group(1)] = meta_match.group(2).strip()

    return metadata, sorted(lyrics, key=lambda x: x[0])  # 按时间排序

def getLyrics(keyword:str):
    response = requests.get(f'http://mobilecdn.kugou.com/api/v3/search/song?format=json&keyword={keyword}&page=1')

    hash = response.json()['data']['info'][0]['hash']

    response = requests.get(f"https://krcs.kugou.com/search?ver=1&man=yes&client=mobi&keyword=&duration=&hash={hash}&album_audio_id=")

    id = response.json()["candidates"][0]["id"]
    accesskey = response.json()["candidates"][0]["accesskey"]

    response = requests.get(f"https://lyrics.kugou.com/download?ver=1&client=pc&id={id}&accesskey={accesskey}&fmt=lrc&charset=utf8")

    content = response.json()['content']

    decoded_bytes = base64.b64decode(content)

    decoded_str = decoded_bytes.decode('utf-8')

    metadata,lyrics = parse_lrc(decoded_str)

    return metadata,lyrics