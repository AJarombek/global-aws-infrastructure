# Commands to work with the official MySQL Docker image.
# Author: Andrew Jarombek
# Date: 10/11/2020

docker run -d --name mysql \
  -e MYSQL_ROOT_PASSWORD=saintsxctftest \
  -e MYSQL_DATABASE=saintsxctf \
  -e MYSQL_USER=test \
  -e MYSQL_PASSWORD=test \
  mysql:5.7

docker container exec -it mysql bash

# From within the container.
mysql --password=saintsxctftest
mysql -u test --password=test saintsxctf

touch backup.sql
echo "DROP TABLE IF EXISTS test;" > backup.sql
mysql -u test --password=test saintsxctf < backup.sql