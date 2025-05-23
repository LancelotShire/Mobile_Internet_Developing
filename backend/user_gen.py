from pymongo import MongoClient

# 连接到本地 MongoDB 服务
client = MongoClient('mongodb://localhost:27017')

db = client['Songs']
collection = db['user']

user = {
    "account": "114514",
    "nickname": "蛇蛇同学",
    "bio": "这个人很懒，什么都没有写",
    "password": "",
    "songlist": [],
    "like": [],
    "search_history": []
}

collection.insert_one(user)