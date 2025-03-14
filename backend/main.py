from fastapi import FastAPI
from pydantic import BaseModel
import datetime
import bcrypt
from pymongo import MongoClient
from bson.objectid import ObjectId
import lyrics

client = MongoClient('mongodb://localhost:27017')

db = client['Songs']
collection = db['info']

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "看到这条消息就代表前后端通讯已经成功了"}

@app.get("/search")
def search(name:str = None):
    return None

@app.get("/getInfo/{Id}")
def getInfo(Id:str):
    result = collection.find_one({"_id": ObjectId(Id)})
    if result:
        result["_id"] = str(result["_id"])
        result["lyrics_metadata"],result["lyrics"] = lyrics.getLyrics(f"{result["song_name"]}{result["singer"]}")
        return result
    return {"error": "Not found"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app,host="127.0.0.1",port=8000)
