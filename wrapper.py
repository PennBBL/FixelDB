import os

os.system("docker run -ti --name mariadb1 --rm -e MYSQL_ROOT_PASSWORD=my-secret-pw -e MYSQL_DATABASE=fixeldb -e MYSQL_USER=fixeluser -e MYSQL_PASSWORD=fixels -d -v $PWD/login.py:/login.py pennbbl/fixeldb")
os.system("docker exec -it mariadb1 python3 ./login.py")
os.system("docker stop $(docker ps | awk '/mariadb/ {print $1}')")
