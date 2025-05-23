from pymongo import MongoClient
from bson.objectid import ObjectId

# 连接到本地 MongoDB 服务
client = MongoClient('mongodb://localhost:27017')

db = client['Songs']
collection = db['songlist']

songlist = {
    "user_id": ObjectId("67d4f2ac2d40303e1077a608"),
    "song": [
        ObjectId("67d3ef835507910649d68899"),
        ObjectId("67d3ef835507910649d68897"),
        ObjectId("67d3ef835507910649d68895"),
        ObjectId("67d3ef835507910649d68894"),
        ObjectId("67d3ef835507910649d68892")
    ]
}

collection.insert_one(songlist)