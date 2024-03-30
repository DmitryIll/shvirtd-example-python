# Домашнее задание к занятию 5. «Практическое применение Docker» - Илларионов Дмитрий

### Инструкция к выполнению

1. Для выполнения заданий обязательно ознакомьтесь с [инструкцией](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD) по экономии облачных ресурсов. Это нужно, чтобы не расходовать средства, полученные в результате использования промокода.
3. **Своё решение к задачам оформите в вашем GitHub репозитории.**
4. В личном кабинете отправьте на проверку ссылку на .md-файл в вашем репозитории.
5. Сопроводите ответ необходимыми скриншотами.

---
## Примечание: Ознакомьтесь со схемой виртуального стенда [по ссылке](https://github.com/netology-code/shvirtd-example-python/blob/main/schema.pdf)

---

## Задача 1
1. Сделайте в своем github пространстве fork репозитория ```https://github.com/netology-code/shvirtd-example-python/blob/main/README.md```.   
2. Создайте файл с именем ```Dockerfile.python``` для сборки данного проекта(для 3 задания изучите https://docs.docker.com/compose/compose-file/build/ ). Используйте базовый образ ```python:3.9-slim```. Протестируйте корректность сборки. Не забудьте dockerignore. 

* _создал .dockerignore но, пока в него писать нечего, т.к. я не копирую папками ничего в докер образ (копирую только то что явно нужно)._
* _создаю образ докера:_

```
FROM python:3.9-slim

ENV DB_HOST=172.20.0.10
ENV DB_TABLE=requests
ENV DB_USER=root
ENV DB_NAME=db1
ENV DB_PASSWORD=12345

WORKDIR /app
COPY requirements.txt ./
RUN pip install -r requirements.txt
COPY main.py ./
CMD ["python", "main.py"]
```

```
docker build  -f Dockerfile.python -t mydoc .
```

![alt text](image.png)

![alt text](image-1.png)


3. (Необязательная часть, *) Изучите инструкцию в проекте и запустите web-приложение без использования docker в venv. (Mysql БД можно запустить в docker run).

_Вот что сделал:_
_Создал файл компоса:_

```
version: '3.7'

# Use root/example as user/password credentials
services:

  mysql:
    image: mysql
    # NOTE: use of "mysql_native_password" is not recommended: https://dev.mysql.com/doc/refman/8.0/en/upgrading-from-previous-series.html#upgrade-caching-sha2-password
    # (this is just an example, not intended to be a production configuration)
    command: --default-authentication-plugin=mysql_native_password
    restart: always
    #env_file: .env
    environment:
      MYSQL_ROOT_PASSWORD: 12345
      MYSQL_USER: user
      MYSQL_PASSWORD: 12345
    ports:
      - 3306:3306
    volumes:
      - ./docker_volumes/mysql:/var/lib/mysql
    networks:
      docker-net:
        ipv4_address: 172.20.0.10

networks:
  docker-net:
    driver: bridge
    ipam:
      config:
      - subnet: 172.20.0.0/24
```

```
apt install mariadb-client-core-10.6
mysql -p -h 172.20.0.10 -P 3306 -u root
```

```
MySQL [(none)]> create database db1;
```


_Запустил - поднял докер контейнер с MYSQL_
_через DBeaver создал db1 и запустил:_

```
export DB_HOST=172.20.0.10 \
export DB_USER=root \
export DB_PASSWORD=12345 \
export DB_NAME=db1

apt install python3.10-venv
python3 -m venv venv
. venv/bin/activate
pip install -r requirements.txt
python main.py
```
_Сделал запрос на внешний адрес и 5000 порт:_

![alt text](image-2.png)

_Но, последующие запросы уже не шли. Вот что было в выводе:_

![alt text](image-3.png)

С пользователем user не заработало, а спользователем root заработало, тк не хватает прав для user - нужно особо выдавать, не стал это делать, а использовал root_



4. (Необязательная часть, *) По образцу предоставленного python кода внесите в него исправление для управления названием используемой таблицы через ENV переменную.

_правки:_

```
db_table=os.environ.get('DB_TABLE')
...
# SQL-запрос для создания таблицы в БД
create_table_query = f"""
CREATE TABLE IF NOT EXISTS {db_database}.{db_table} (
id INT AUTO_INCREMENT PRIMARY KEY,
request_date DATETIME,
request_ip VARCHAR(255)
)
"""
...

    query = f"""INSERT INTO {db_table} (request_date, request_ip) VALUES (%s, %s)"""

```

и переменные теперь так:

```sh
export DB_HOST=172.20.0.10 \
export DB_USER=root \
export DB_PASSWORD=12345 \
export DB_NAME=db1 \
export DB_TABLE=requests \
```

Остальное без изменений.

Заработало:

![alt text](image-5.png)

интересно что значит конструкция f"""...""" и чем отличатеся от "..." ?

---
### ВНИМАНИЕ!
!!! В процессе последующего выполнения ДЗ НЕ изменяйте содержимое файлов в fork-репозитории! Ваша задача ДОБАВИТЬ 5 файлов: ```Dockerfile.python```, ```compose.yaml```, ```.gitignore```, ```.dockerignore```,```bash-скрипт```. Если вам понадобилось внести иные изменения в проект - вы что-то делаете неверно!
---

## Задача 2 (*)
1. Создайте в yandex cloud container registry с именем "test" с помощью "yc tool" . [Инструкция](https://cloud.yandex.ru/ru/docs/container-registry/quickstart/?from=int-console-help)
2. Настройте аутентификацию вашего локального docker в yandex container registry.
3. Соберите и залейте в него образ с python приложением из задания №1.
4. Просканируйте образ на уязвимости.
5. В качестве ответа приложите отчет сканирования.

### Решение

```
docker build -t myapp -f Dockerfile.python .
```

![alt text](image-10.png)
![alt text](image-9.png)

```
docker compose up -d
```

![alt text](image-11.png)

```
docker logs 5f321a9917f9
```

![alt text](image-12.png)

```
apt install mysql-client-core-8.0
mysql -p -h 172.20.0.10 -P 3306 -u root --password=12345   --init-command="create database db1;"
```

```
mysql> show databases;
```

![alt text](image-13.png)

```
docker compose up -d
```

![alt text](image-14.png)

![alt text](image-15.png)


```
root@dp:~/shvirtd-example-python# curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
```

![alt text](image-16.png)

```
yc container registry create --name test
```
![alt text](image-17.png)

```
yc container registry configure-docker
```

![alt text](image-18.png)

```
docker tag myapp cr.yandex/crp5gbscd8f2re1ga8ip/myapp:latest
docker push cr.yandex/crp5gbscd8f2re1ga8ip/myapp
```

![alt text](image-19.png)

```
yc container image list --repository-name=crp5gbscd8f2re1ga8ip/myapp
```

![alt text](image-20.png)

```
yc container image scan crprcak0gm7fn41j9ik2
```

началось сканирование образа:
![alt text](image-8.png)

![alt text](image-21.png)

```
yc container image list-vulnerabilities --scan-result-id=chekusor1mibehitcpu6
```

![alt text](image-22.png)

Критическая уязвимость: https://avd.aquasec.com/nvd/2023/cve-2023-45853/


Инструкция:
https://yandex.cloud/ru/docs/container-registry/operations/scanning-docker-image





## Задача 3
1. Изучите файл "proxy.yaml"
2. Создайте в репозитории с проектом файл ```compose.yaml```. С помощью директивы "include" подключите к нему файл "proxy.yaml".
_файл уже создал ранее, тут теперь его редактирую_

3. Опишите в файле ```compose.yaml``` следующие сервисы: 

- ```web```. Образ приложения должен ИЛИ собираться при запуске compose из файла ```Dockerfile.python``` ИЛИ скачиваться из yandex cloud container registry(из задание №2 со *). Контейнер должен работать в bridge-сети с названием ```backend``` и иметь фиксированный ipv4-адрес ```172.20.0.5```. Сервис должен всегда перезапускаться в случае ошибок.
Передайте необходимые ENV-переменные для подключения к Mysql базе данных по сетевому имени сервиса ```web``` 

код сервиа:

```
  web:
    image: myapp
    restart: on-failure
    environment:
      - DB_HOST=172.20.0.10
      - DB_TABLE=requests
      - DB_USER=root
      - DB_NAME=db1
      - DB_PASSWORD=12345
    depends_on:
      - db
    ports:
      - 5000:5000
    networks:
      backend:
        ipv4_address: 172.20.0.5
```


- ```db```. image=mysql:8. Контейнер должен работать в bridge-сети с названием ```backend``` и иметь фиксированный ipv4-адрес ```172.20.0.10```. Явно перезапуск сервиса в случае ошибок. Передайте необходимые ENV-переменные для создания: пароля root пользователя, создания базы данных, пользователя и пароля для web-приложения.Обязательно используйте уже существующий .env file для назначения секретных ENV-переменных!

код сервиса:
```
  db:
    image: mysql:8
    # NOTE: use of "mysql_native_password" is not recommended: https://dev.mysql.com/doc/refman/8.0/en/upgrading-from-previous-series.html#upgrade-caching-sha2-password
    # (this is just an example, not intended to be a production configuration)
    command: --default-authentication-plugin=mysql_native_password
    restart: on-failure
    #env_file: .env
    environment:
      MYSQL_ROOT_PASSWORD: 12345
      MYSQL_USER: user
      MYSQL_PASSWORD: 12345
    ports:
      - 3306:3306
    volumes:
      - ./docker_volumes/mysql:/var/lib/mysql
    networks:
      backend:
        ipv4_address: 172.20.0.10
```


2. Запустите проект локально с помощью docker compose , добейтесь его стабильной работы: команда ```curl -L http://127.0.0.1:8090``` должна возвращать в качестве ответа время и локальный IP-адрес. Если сервисы не стартуют воспользуйтесь командами: ```docker ps -a ``` и ```docker logs <container_name>``` 

![alt text](image-23.png)

5. Подключитесь к БД mysql с помощью команды ```docker exec <имя_контейнера> mysql -uroot -p<пароль root-пользователя>``` . Введите последовательно команды (не забываем в конце символ ; ): ```show databases; use <имя вашей базы данных(по-умолчанию example)>; show tables; SELECT * from requests LIMIT 10;```.

_выполнил не в контейнере а с хостовой машины - так как все равно арнее поставил Mysql_

![alt text](image-24.png)

![alt text](image-25.png)

```
mysql> SELECT * from requests order by id desc limit 20;
```
![alt text](image-26.png)

6. Остановите проект. В качестве ответа приложите скриншот sql-запроса.

_не понял, что значит "остановить проект"? остановить все контейнеры? тогда как можно получить результат запроса если контейнер с БД остановлен?_

```
 docker compose down
```
![alt text](image-27.png)

Подключиться к БД уже не получается.

## Задача 4
1. Запустите в Yandex Cloud ВМ (вам хватит 2 Гб Ram).

_уже сразу так и сделал_

2. Подключитесь к Вм по ssh и установите docker.

_докер установлен при создании ВМ через терраформ:_

```
  provisioner "remote-exec" {
    inline = [
    "sudo apt-get update",
    "sudo apt-get install -y ca-certificates curl gnupg",
    "sudo install -m 0755 -d /etc/apt/keyrings",
    "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
    "sudo chmod a+r /etc/apt/keyrings/docker.gpg",
    "echo \"deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \"$(. /etc/os-release && echo \"$VERSION_CODENAME\")\" stable\" |  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
    "sudo apt-get update",
    "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
    "sudo chmod +x /root/proxy.yaml",
    "apt install -y mariadb-client-core-10.6 ",
    "git clone https://github.com/DmitryIll/shvirtd-example-python.git"
    ]
  }
```


3. Напишите bash-скрипт, который скачает ваш fork-репозиторий в каталог /opt и запустит проект целиком.

_я скачал в дирректорию root. Но, можно и opt - не принципиально._

```
    cd /opt
    git clone https://github.com/DmitryIll/shvirtd-example-python.git
```
Опять пришлось новую БД создать:
![alt text](image-29.png)


4. Зайдите на сайт проверки http подключений, например(или аналогичный): ```https://check-host.net/check-http``` и запустите проверку вашего сервиса ```http://<внешний_IP-адрес_вашей_ВМ>:8090```. Таким образом трафик будет направлен в ingress-proxy.

![alt text](image-30.png)



5. (Необязательная часть) Дополнительно настройте remote ssh context к вашему серверу. Отобразите список контекстов и результат удаленного выполнения ```docker ps -a```
6. В качестве ответа повторите  sql-запрос и приложите скриншот с данного сервера, bash-скрипт и ссылку на fork-репозиторий.

![alt text](image-31.png)

https://github.com/DmitryIll/shvirtd-example-python.git

Скрипты команд, наработанные когда вручную запускал (в формате заметок):

```
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


apt install mysql-client-core-8.0 
mysql --password=mypassword --user=me --host=etc
mysql -p -h 172.20.0.10 -P 3306 -u root --password=12345   --init-command="create database db1;"
mysql show databases;
mysql -p -h 172.20.0.10 -P 3306 -u root --password=12345 

mysql> select * from db1.requests;
```


## Задача 5 (*)
1. Напишите и задеплойте на вашу облачную ВМ bash скрипт, который произведет резервное копирование БД mysql в директорию "/opt/backup" с помощью запуска в сети "backend" контейнера из образа ```schnitzler/mysqldump``` при помощи ```docker run ...``` команды. Подсказка: "документация образа."
2. Протестируйте ручной запуск
3. Настройте выполнение скрипта раз в 1 минуту через cron, crontab или systemctl timer. Придумайте способ не светить логин/пароль в git!!
4. Предоставьте скрипт, cron-task и скриншот с несколькими резервными копиями в "/opt/backup"

## Задача 6
Скачайте docker образ ```hashicorp/terraform:latest``` и скопируйте бинарный файл ```/bin/terraform``` на свою локальную машину, используя dive и docker save.
Предоставьте скриншоты  действий .

### Решение

```
docker pull hashicorp/terraform:latest
```
![alt text](image-32.png)

![alt text](image-33.png)

Нашел в каком слое появился файл терраформа:
![alt text](image-34.png)

слой sha256:b22c6fe345f979d4956c9570f757a0d13f1d7abf0b26121f3adfed2cf580c055


Выгружаю образ:
```
docker save hashicorp/terraform -o image.tar
```
Распокавал:
![alt text](image-35.png)

Нашел нужный слой и распаковал его:

![alt text](image-36.png)

![alt text](image-37.png)

## Задача 6.1
Добейтесь аналогичного результата, используя docker cp.  
Предоставьте скриншоты  действий .

Запускаю контейнер пусть даже с ошибкой:

![alt text](image-38.png)

смотрю контейнеры:

![alt text](image-39.png)

Далее копирую все из bin

![alt text](image-40.png)

или можно точнее сразу:

![alt text](image-41.png)


## Задача 6.2 (**)
Предложите способ извлечь файл из контейнера, используя только команду docker build и любой Dockerfile.  
Предоставьте скриншоты  действий .

## Задача 7 (***)
Запустите ваше python-приложение с помощью runC, не используя docker или containerd.  
Предоставьте скриншоты  действий .
