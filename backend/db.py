from pymongo import MongoClient

client = MongoClient('mongodb://localhost:27017')
db_instance = client['Songs']