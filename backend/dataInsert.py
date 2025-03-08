from pymongo import MongoClient

# 连接到本地 MongoDB 服务
client = MongoClient('mongodb://localhost:27017')

db = client['Songs']
collection = db['information']

information = [
    {
        "song_name": "Da Capo",
        "singer": "HOYO-MiX",
        "album":"Da Capo",
        "description": "《崩坏三》手游终章《毕业旅行》动画短片印象曲",
        "url": "https://static.lancelotshire.me/music/HOYO-MiX-DaCapo.mp3",
        "picture": "https://static.lancelotshire.me/album_picture/DaCapo.jpg",
        "lyrics": "",
    },
    {
        "song_name": "Moon Halo",
        "singer": "茶理理理子、TetraCalyx、hanser",
        "album":"Moon Halo",
        "description": "《崩坏三》手游《薪炎永燃》动画短片印象曲",
        "url": "https://static.lancelotshire.me/music/MoonHalo-%E8%8C%B6%E7%90%86%E7%90%86%E7%90%86%E5%AD%90.mp3",
        "picture": "https://static.lancelotshire.me/album_picture/MoonHalo.jpg",
        "lyrics": "",
    },
    {
        "song_name": "Lemon",
        "singer": "米津玄師",
        "album":"Lemon",
        "description": "《非自然死亡》电视剧主题曲",
        "url": "https://static.lancelotshire.me/music/Lemon-%E7%B1%B3%E6%B4%A5%E7%8E%84%E5%B8%AB.mp3",
        "picture": "https://static.lancelotshire.me/album_picture/Lemon.jpg",
        "lyrics": "",
    },
    {
        "song_name": "LOSER",
        "singer": "米津玄師",
        "album":"ナンバーナイン",
        "description": "https://static.lancelotshire.me/album_picture/NumberNine.jpg",
        "url": "https://static.lancelotshire.me/music/LOSER-%E7%B1%B3%E6%B4%A5%E7%8E%84%E5%B8%AB.mp3",
        "picture": "",
        "lyrics": "",
    },
    {
        "song_name": "KICK BACK",
        "singer": "米津玄師",
        "album":"KICK BACK",
        "description": "《链锯人》动画OP",
        "url": "https://static.lancelotshire.me/music/LOSER-%E7%B1%B3%E6%B4%A5%E7%8E%84%E5%B8%AB.mp3",
        "picture": "https://static.lancelotshire.me/album_picture/KICKBACK.jpg",
        "lyrics": "",
    },
    {
        "song_name": "さよーならまたいつか！- Sayonara",
        "translation": "终有一日再会！",
        "singer": "米津玄師",
        "album":"さよーならまたいつか！- Sayonara",
        "description": "《如虎添翼》电视剧主题曲",
        "url": "https://static.lancelotshire.me/music/%E3%81%95%E3%82%88%E3%83%BC%E3%81%AA%E3%82%89%E3%81%BE%E3%81%9F%E3%81%84%E3%81%A4%E3%81%8B%EF%BC%81-%E7%B1%B3%E6%B4%A5%E7%8E%84%E5%B8%AB.mp3",
        "picture": "https://static.lancelotshire.me/album_picture/Sayonaramataituka.jpg",
        "lyrics": "",
    },
    {
        "song_name": "死神",
        "singer": "米津玄師",
        "album":"Pale Blue",
        "description": "",
        "url": "https://static.lancelotshire.me/music/%E6%AD%BB%E7%A5%9E-%E7%B1%B3%E6%B4%A5%E7%8E%84%E5%B8%AB.mp3",
        "picture": "https://static.lancelotshire.me/album_picture/PaleBlue.jpg",
        "lyrics": "",
    },
    {
        "song_name": "青空",
        "singer": "Candy_Wind",
        "album":"雨之翼",
        "description": "",
        "url": "https://static.lancelotshire.me/music/%E9%9D%92%E7%A9%BA-Candy_Wind.mp3",
        "picture": "https://static.lancelotshire.me/album_picture/%E9%9B%A8%E4%B9%8B%E7%BF%BC.jpg",
        "lyrics": None,
    }
]

collection.insert_many(information)