from pymongo import collection as collection
from bson.objectid import ObjectId

class BaseDAO:
    def __init__(self, collection: collection.Collection):
        self.collection = collection

    def insert_one(self, data):
        return self.collection.insert_one(data).inserted_id

    def insert_many(self, data_list):
        return self.collection.insert_many(data_list).inserted_ids

    def find_one(self, query):
        return self.collection.find_one(query)

    def find_many(self, query, skip=0, limit=100):
        return list(self.collection.find(query).skip(skip).limit(limit))

    def update_one(self, query, update_data: dict):
        update_data = {k: v for k, v in update_data.items() if v is not None}
        return self.collection.update_one(query, {"$set": update_data}).modified_count
    
    def update_many(self, query, update_data: dict):
        update_data = {k: v for k, v in update_data.items() if v is not None}
        return self.collection.update_many(query, {"$set": update_data}).modified_count
    
    def delete_one(self, query):
        return self.collection.delete_one(query).deleted_count

    def delete_many(self, query):
        return self.collection.delete_many(query).deleted_count
    
    def aggregate(self, pipeline):
        return list(self.collection.aggregate(pipeline))
    
    
    @staticmethod
    # 将蛇形命名转化为驼峰命名
    def snake_to_camel(snake_str:str):
        components = snake_str.split('_')
        # 第一个组件保持小写，其他组件首字母大写
        return components[0] + ''.join(x.title() for x in components[1:])

    # 递归处理字典，转换键名并替换 _id 为 id
    @staticmethod
    def map(d):
        if isinstance(d, ObjectId):
            return str(d)

        elif isinstance(d, dict):
            new_dict = {}
            for key, value in d.items():
                new_key = 'id' if key == '_id' else BaseDAO.snake_to_camel(key)
                new_dict[new_key] = BaseDAO.map(value)
            return new_dict

        elif isinstance(d, list):
            return [BaseDAO.map(item) for item in d]

        else:
            return d
