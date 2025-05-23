from baseDAO import BaseDAO
from db import db_instance as db
from bson import ObjectId

class SonglistDAO(BaseDAO):
    def __init__(self):
        super().__init__(db.get_collection("songlist"))

    def get_all_songlist_by_user(self, user_id: str):
        query = {"user_id": ObjectId(user_id)}
        result = self.find_many(query)
        if result:
            for res in result:
                res["_id"] = str(res["_id"])
                # 删除不需要的字段
                res.pop("user_id", None)
                res.pop("song", None)
                res["songlist_name"] = res["songlist_name"]
            return result
        return {"error": "Not found"}
        
    def get_songlist_info(self, id: str):
        result = self.find_one({"_id": ObjectId(id)})
        if result:
            result["_id"] = str(result["_id"])
            result["user_id"] = str(result["user_id"])
            result["song"] = [str(x) for x in result["song"]] if result["song"] else []
            result["songlist_name"] = result["songlist_name"]
            return result
        return {"error": "Not found"}
    
    def add_songlist(self, user_id: str, song: list, songlist_name: str):
        data = {
            "user_id": ObjectId(user_id),
            "song": [ObjectId(x) for x in song] if song else [],
            "songlist_name": songlist_name if songlist_name else "默认歌单"
        }
        return self.insert_one(data)
    
    def delete_songlist(self, id: str):
        return self.delete_one({"_id": ObjectId(id)})
    
    def update_songlist(self, id: str, songlist_name: str, song: list):
        data = {
            "songlist_name": songlist_name,
            "song": [ObjectId(x) for x in song] if song is not None else None
        }
        return self.update_one({"_id": ObjectId(id)}, data)