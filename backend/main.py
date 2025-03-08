from fastapi import FastAPI
from pydantic import BaseModel
import datetime
import bcrypt
from pymongo import MongoClient

client = MongoClient('mongodb://localhost:27017')

db = client['Songs']
collection = db['information']

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "看到这条消息就代表前后端通讯已经成功了"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app,host="127.0.0.1",port=8000)
