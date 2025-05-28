import random
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import datetime
import bcrypt
from pymongo import MongoClient
from bson.objectid import ObjectId
from bson import json_util
import lyrics
import json
from db import db_instance as db
from userDAO import UserDAO
from infoDAO import InfoDAO
import time
from songlistDAO import SonglistDAO

app = FastAPI()

# 允许前端的地址访问API
origins = [
    "*"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,  # 允许的源
    allow_credentials=True,
    allow_methods=["*"],    # 允许所有方法
    allow_headers=["*"],    # 允许所有请求头
)

@app.get("/")
def read_root():
    return {"message": "看到这条消息就代表前后端通讯已经成功了"}

@app.get("/search")
def search(name:str = None):
    result = InfoDAO().search(name=name)
    return result
    
@app.get("/getInfo/{id}")
def getInfo(id:str):
    result = InfoDAO().getInfo(id)
    return result

class SearchHistroy (BaseModel):
    user_id: str
    search_history: str
@app.post("/addSearchHistory")
def addSearchHistory(search: SearchHistroy):
    user_id = search.user_id
    search_history = search.search_history
    UserDAO().add_search_history(ObjectId(user_id), search_history)
    return {"message": "Search history added successfully"}

@app.get("/getSearchHistory/{id}")
def getSearchHistory(id:str):
    user = UserDAO().get_search_history(ObjectId(id))
    if user:
        return user
    return {"error": "Not found"}

@app.delete("/deleteSearchHistory/{id}")
def deleteSearchHistory(id:str):
    UserDAO().delete_search_history(ObjectId(id))
    return {"message": "Search history deleted successfully"}

@app.get("/getUserInfo/{id}")
def getUserInfo(id:str):
    user = UserDAO().get_user_info(ObjectId(id))
    if user:
        return user
    return {"error": "Not found"}

class User(BaseModel):
    id: str
    account: str = None
    nickname: str = None
    bio: str = None
    password: str = None
    songlist: list = None
    like: list = None
    search_history: list = None
    play_history: list = None
@app.put("/updateUserInfo")
def updateUserInfo(user: User):
    id = user.id
    account = user.account
    nickname = user.nickname
    bio = user.bio
    password = user.password
    songlist = user.songlist
    like = user.like
    play_history = user.play_history
    search_history = user.search_history
    UserDAO().update_user_info(ObjectId(id), nickname, password, bio, songlist, like, search_history, play_history)
    return {"message": "User info updated successfully"}

@app.get("/getSonglist/{id}")
def getSonglist(id:str):
    result = SonglistDAO().get_all_songlist_by_user(id)
    if result:
        return result
    return []

@app.get("/getSonglistInfo/{id}")
def getSonglistInfo(id:str):
    result = SonglistDAO().get_songlist_info(id)
    if result:
        return result
    return {"error": "Not found"}

class SonglistInfoByList(BaseModel):
    songlist: list
@app.post("/getSonglistInfoByList")
def getSonglistInfoByList(songl: SonglistInfoByList):
    songlist = songl.songlist
    result = InfoDAO().get_song_info_by_list(songlist)
    if result:
        return result
    return []

class Songlist(BaseModel):
    user_id: str
    song: list = []
    songlist_name: str = "默认歌单"
@app.post("/addSonglist")
def addSonglist(songlist: Songlist):
    user_id = songlist.user_id
    song = songlist.song
    songlist_name = songlist.songlist_name
    SonglistDAO().add_songlist(user_id, song, songlist_name)
    return {"message": "Songlist added successfully"}

class UpdateSonglist(BaseModel):
    id: str
    song: list = None
    songlist_name: str = None
@app.put("/updateSonglist")
def updateSonglist(songlist: UpdateSonglist):
    id = songlist.id
    songlist_name = songlist.songlist_name
    song = songlist.song
    SonglistDAO().update_songlist(id, songlist_name, song)
    return {"message": "Songlist updated successfully"}

@app.delete("/deleteSonglist/{id}")
def deleteSonglist(id:str):
    SonglistDAO().delete_songlist(id)
    return {"message": "Songlist deleted successfully"}

class addToSonglist(BaseModel):
    id: str
    song_id: str

@app.put("/addSongToSonglist")
def addSongToSonglist(add: addToSonglist):
    id = add.id
    song = add.song_id
    songlist = SonglistDAO().get_songlist_info(id)
    if songlist is not None and song not in songlist["song"]:
        songlist["song"].append(song)
        SonglistDAO().update_songlist(id, songlist["songlist_name"], songlist["song"])
        return {"message": "Song added to songlist successfully"}
    return {"error": "Not found"}

@app.delete("/deleteSongFromSonglist/{id}/{song_id}")
def deleteSongFromSonglist(id:str, song_id:str):
    songlist = SonglistDAO().get_songlist_info(id)
    if songlist is not None and song_id in songlist["song"]:
        songlist["song"].remove(song_id)
        SonglistDAO().update_songlist(id, songlist["songlist_name"], songlist["song"])
        return {"message": "Song deleted from songlist successfully"}
    return {"error": "Not found"}

@app.get("/getPlayHistory/{id}")
def getPlayHistory(id:str):
    user = UserDAO().get_user_info(ObjectId(id))
    if user:
        return user["play_history"]
    return []

class PlayHistory(BaseModel):
    user_id: str
    play_history: str = None
@app.put("/addPlayHistory")
def addPlayHistory(play: PlayHistory):
    user_id = play.user_id
    play_history = play.play_history
    playh = getPlayHistory(user_id)
    if play_history in playh:
        playh.remove(play_history)
        playh.insert(0, play_history)
    else:
        playh.insert(0, play_history)
    if len(playh) > 10:
        playh = playh[:10]
    UserDAO().update_user_info(ObjectId(user_id), None, None, None, None, None, None, playh)
    return {"message": "Play history added successfully"}

@app.get("/getEverydayRecommendation")
def getEverydayRecommendation():
    recoList = [("崩坏三OST",("Da Capo", "Moon Halo"),"https://static.lancelotshire.me/album_picture/DaCapo.jpg"),
                ("《如虎添翼》主题曲",("さよーならまたいつか！- sayonara",),"https://static.lancelotshire.me/album_picture/Sayonaramataituka.jpg"),
                ("米津玄师的经典歌曲",("LOSER","Lemon"),"https://static.lancelotshire.me/album_picture/NumberNine.jpg"),
                 ("纯音乐",("青空",),"https://static.lancelotshire.me/album_picture/%E9%9B%A8%E4%B9%8B%E7%BF%BC.jpg"),
                ("《链锯人》动画OP",("KICK BACK",),"https://static.lancelotshire.me/album_picture/KICKBACK.jpg"),
                ("Pale Blue",("死神",),"https://static.lancelotshire.me/album_picture/PaleBlue.jpg")]
    reco = random.sample(recoList, k=3)
    for i in range(len(reco)):
        recoName = reco[i][0]
        recoSong = reco[i][1]
        recoPic = reco[i][2]
        songlist = InfoDAO().get_song_by_song_name(recoSong)
        reco[i] = {
            "songlist_name": recoName,
            "song": songlist,
            "cover": recoPic
        }
    return reco

@app.get("/getRecommendedSinger")
def getRecommendedSinger():
    singer = "茶理理理子、TetraCalyx、hanser、米津玄師、HOYO-MiX、Candy_Wind".split("、")
    singer = random.choice(singer)
    return InfoDAO().get_song_by_singer(singer)

class UserRegister(BaseModel):
    account: str
    password: str
@app.post("/register")
def register(user: UserRegister):
    account = user.account
    password = user.password
    nickname = "用户"+str(int(time.time()))
    if UserDAO().find_one({"account": account}):
        return {"message": "Account already exists", "code": 1}
    else:
        UserDAO().add_user(account, nickname, password)
        return {"message": "User registered successfully", "code": 0}
    
@app.post("/login")
def login(user: UserRegister):
    account = user.account
    password = user.password
    print(account)
    print(password)
    user = UserDAO().find_by_account(account)
    print(user)
    if user:
        if password == user["password"]:
            return {"message": "Login successful", "code": 0, "user": str(user["_id"])}
        else:
            return {"message": "Incorrect password", "code": 1}
    else:
        return {"message": "Account not found", "code": 2}
    
@app.get("/getAllUsers")
def getAllUsers():
    users = UserDAO().find_users()
    print(users)
    for user in users:
        user["_id"] = str(user["_id"])
        user["songlist"] = [str(x) for x in user["songlist"]] if user["songlist"] else []
        user["like"] = [str(x) for x in user["like"]] if user["like"] else []
        user["play_history"] = [str(x) for x in user["play_history"]] if user["play_history"] else []
    return users

@app.delete("/deleteUser/{id}")
def deleteUser(id:str):
    UserDAO().delete_user(ObjectId(id))
    return {"message": "User deleted successfully"}

@app.get("/getAllSongs")
def getAllSongs():
    songs = InfoDAO().get_all_songs()
    for song in songs:
        song["_id"] = str(song["_id"])
    return songs

class UpdateSongInfo(BaseModel):
    id: str
    song_name: str = None
    singer: str = None
    album: str = None
    translation: str = None
    description: str = None
    url: str = None
    picture: str = None
@app.put("/updateSongInfo")
def updateSongInfo(song: UpdateSongInfo):
    id = song.id
    song_name = song.song_name
    singer = song.singer
    album = song.album
    translation = song.translation
    description = song.description
    url = song.url
    picture = song.picture
    InfoDAO().update_song_info(id, song_name, singer, album, description, translation, url, picture)
    return {"message": "Song info updated successfully"}

class AddSong(BaseModel):
    song_name: str = ""
    singer: str = ""
    album: str = ""
    translation: str = ""
    description: str = ""
    url: str = ""
    picture: str = ""
@app.post("/addSong")
def addSong(song: AddSong):
    song_name = song.song_name
    singer = song.singer
    album = song.album
    translation = song.translation
    description = song.description
    url = song.url
    picture = song.picture
    InfoDAO().add_song(song_name, singer, album, description, translation, url, picture)
    return {"message": "Song info added successfully"}

@app.delete("/deleteSong/{id}")
def deleteSong(id:str):
    InfoDAO().delete_song(id)
    return {"message": "Song deleted successfully"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app,host="0.0.0.0",port=8000)
