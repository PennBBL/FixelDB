import mysql.connector
import os

print('Python here!')

os.system('mariadb --version')
cnx = mysql.connector.connect(user='fixeluser', password='fixels', database='fixeldb')
cursor = cnx.cursor()
cursor.fetchall()
