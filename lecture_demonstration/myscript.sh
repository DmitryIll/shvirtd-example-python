docker network create --driver=bridge net1 

#Запускаем контейнер с Mysql в сети 'wordpress'. Благо вольюм сздается автоматически!
docker run -d --network='net1' --hostname='mysql' -v 'db_data:/var/lib/mysql' -e 'MYSQL_ROOT_PASSWORD=12345' -e 'MYSQL_DATABASE=db1' -e 'MYSQL_USER=user' -e 'MYSQL_PASSWORD=12345' mariadb:10.6.4-focal  --default-authentication-plugin='mysql_native_password'


export DB_HOST=172.20.0.10 \
export DB_USER=root \
export DB_PASSWORD=12345 \
export DB_NAME=db1 \
export DB_TABLE=requests \


db_host=os.environ.get('DB_HOST')
db_user=os.environ.get('DB_USER')
db_password=os.environ.get('DB_PASSWORD')
db_database=os.environ.get('DB_NAME')