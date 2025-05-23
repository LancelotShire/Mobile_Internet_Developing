from baseDAO import BaseDAO
from db import db_instance as db
from bson import ObjectId
import lyrics

class InfoDAO(BaseDAO):
    def __init__(self):
        super().__init__(db.get_collection("info"))

    def search(self, name: str):
        if name == "subete":
            name = ""
        query1 = {"$or": [{"song_name": {"$regex": f"{name}", "$options": "i"}},
                          {"description": {"$regex": f"{name}", "$options": "i"}},
                          {"translation": {"$regex": f"{name}", "$options": "i"}}]}
        query2 = {"singer": {"$regex": f"{name}", "$options": "i"}}
        query3 = {"album": {"$regex": f"{name}", "$options": "i"}}
        query4 = {"$or": [{"song_name": {"$regex": f"{name}", "$options": "i"}},
                          {"description": {"$regex": f"{name}", "$options": "i"}},
                          {"singer": {"$regex": f"{name}", "$options": "i"}},
                          {"album": {"$regex": f"{name}", "$options": "i"}},
                          {"translation": {"$regex": f"{name}", "$options": "i"}}]}
        result1 = self.find_many(query1)
        result2 = self.find_many(query2)
        result3 = self.find_many(query3)
        result4 = self.find_many(query4)
        if result1:
            for res in result1:
                res["_id"] = str(res["_id"])
        if result2:
            for res in result2:
                res["_id"] = str(res["_id"])
        if result3:
            for res in result3:
                res["_id"] = str(res["_id"])
        if result4:
            for res in result4:
                res["_id"] = str(res["_id"])
        
        return {
            "by_song": result1,
            "by_singer": result2,
            "by_album": result3,
            "all": result4
        }
    
    def getInfo(self, id: str):
        result = self.find_one({"_id": ObjectId(id)})
        if result:
            result["_id"] = str(result["_id"])
            result["lyrics_metadata"],result["lyrics"] = lyrics.getLyrics(f"{result["song_name"]}{result["singer"]}")
            return result
        return {"error": "Not found"}
    
    def get_song_info_by_list(self, songlist: list):
        result = []
        for id in songlist:
            res = self.find_one({"_id": ObjectId(id)})
            res["_id"] = str(res["_id"])
            result.append(res)
        return result
    
    def get_song_by_singer(self, singer: str):
        query = {"singer": {"$regex": f".*{singer}.*", "$options": "i"}}
        songInfoList = self.find_many(query)
        songlist = []
        for songInfo in songInfoList:
            songInfo["_id"] = str(songInfo["_id"])
        for songInfo in songInfoList:
            songlist.append(str(songInfo["_id"]))
        return {
            "singer": singer,
            "songlist": songlist,
            "songInfoList": songInfoList
        }
    
    def get_song_by_song_name(self, song_names: tuple):
        query = {
            "$or": [
                {"song_name": {"$regex": f".*{name}.*", "$options": "i"}}
                for name in song_names
            ]
        }
        songInfoList = self.find_many(query)
        songlist = []
        for songInfo in songInfoList:
            songlist.append(str(songInfo["_id"]))
        return songlist
    #歌曲只能查，添加/修改/删除歌曲需要我在后台手动添加