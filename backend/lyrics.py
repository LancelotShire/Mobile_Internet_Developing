import base64
import requests
import re
import time

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

def getLyrics(keyword: str):
    headers = {
        "User-Agent": "Mozilla/5.0"
    }

    try:
        # Step 1: 获取 hash
        search_resp = requests.get(
            f'http://mobilecdn.kugou.com/api/v3/search/song?format=json&keyword={keyword}&page=1',
            headers=headers,
            timeout=5
        )
        search_resp.raise_for_status()
        infos = search_resp.json().get("data", {}).get("info", [])
        if not infos:
            print(f"[WARN] 未找到歌曲: {keyword}")
            return None, None
        hash_val = infos[0].get("hash")
        if not hash_val:
            print(f"[WARN] hash 获取失败: {keyword}")
            return None, None

        # Step 2: 获取歌词ID 和 accesskey
        search_lyric_resp = requests.get(
            f"https://krcs.kugou.com/search?ver=1&man=yes&client=mobi&keyword=&duration=&hash={hash_val}&album_audio_id=",
            headers=headers,
            timeout=5
        )
        search_lyric_resp.raise_for_status()
        candidates = search_lyric_resp.json().get("candidates", [])
        if not candidates:
            print(f"[WARN] 歌词候选为空: {keyword}")
            return None, None
        lyric_id = candidates[0].get("id")
        accesskey = candidates[0].get("accesskey")

        if not lyric_id or not accesskey:
            print(f"[WARN] id 或 accesskey 获取失败: {keyword}")
            return None, None

        # Step 3: 下载歌词
        download_resp = requests.get(
            f"https://lyrics.kugou.com/download?ver=1&client=pc&id={lyric_id}&accesskey={accesskey}&fmt=lrc&charset=utf8",
            headers=headers,
            timeout=10
        )
        download_resp.raise_for_status()
        content = download_resp.json().get("content")
        if not content:
            print(f"[WARN] 歌词内容为空: {keyword}")
            return None, None

        # Step 4: 解码歌词
        decoded_str = base64.b64decode(content).decode("utf-8")
        metadata, lyrics = parse_lrc(decoded_str)

        return metadata, lyrics

    except (requests.exceptions.RequestException, KeyError, IndexError, ValueError) as e:
        print(f"[ERROR] 获取歌词失败: {keyword}，原因：{e}")
        return None, None

    finally:
        # 可选：给接口减压，避免被封
        time.sleep(0.3)