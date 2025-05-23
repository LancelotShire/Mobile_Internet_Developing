from baseDAO import BaseDAO
from db import db_instance as db
from bson import ObjectId

class UserDAO(BaseDAO):
    def __init__(self):
        super().__init__(db.get_collection("user"))
    
    def find_by_id(self, id: ObjectId):
        return self.find_one({"_id": id})
    
    def find_by_account(self, account: str):
        return self.find_one({"account": account})
    
    def find_users(self):
        return self.find_many({})
    
    def update_user_info(self,id:ObjectId,nickname,password,bio,songlist,like,search_history, play_history):
        data = {
                "nickname": nickname,
                "password": password,
                "bio": bio,
                "songlist": [ObjectId(x) for x in songlist] if songlist is not None else None,
                "like": [ObjectId(x) for x in like] if like is not None else None,
                "search_history": search_history,
                "play_history": [ObjectId(x) for x in play_history] if play_history is not None else None
            }
        return self.update_one({"_id": id}, data)
    
    def get_search_history(self, id:ObjectId):
        user = self.find_by_id(id)
        if user:
            return {'search_history': user['search_history']}
        return []
    
    def get_user_info(self, id:ObjectId):
        user = self.find_by_id(id)
        if user:
            return {
                'nickname': user['nickname'],
                'bio': user['bio'],
                'songlist': [str(x) for x in user['songlist']] if user['songlist'] else [],
                'like': [str(x) for x in user['like']] if user['like'] else [],
                'search_history': user['search_history'] if user['search_history'] else [],
                'play_history': [str(x) for x in user['play_history']] if user['play_history'] else []
            }
        return None
    
    def add_search_history(self, id:ObjectId, search_history):
        user = self.find_by_id(id)
        if user and (search_history not in user['search_history']):
            user['search_history'].append(search_history)
            self.update_one({'_id': id}, {'search_history': user['search_history']})
        return None
    
    def delete_search_history(self, id:ObjectId):
        user = self.find_by_id(id)
        if user:
            user['search_history'] = []
            self.update_one({'_id': id}, {'search_history': user['search_history']})
        return None
    
    def delete_user(self, id:ObjectId):
        return self.delete_one({"_id": id})
    
    def add_user(self, account, nickname, password):
        return self.insert_one({
            "account": account,
            "nickname": nickname,
            "password": password,
            "bio": "",
            "songlist": [],
            "like": [],
            "search_history": [],
            "play_history": []
        })
    