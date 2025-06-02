


ksm init default "US:45LwnEVRdwHfolqCLrYSEUbHvRUNBq9SArfQ4zdxpHI" > ksmconfig.b64


docker build -t d1 .

docker run \
-v "$(pwd)/volume:/data" \
-e MYSQL_ROOT_PASSWORD='keeper://YrXVDkmvSvQp_r4w4MmVLw/custom_field/rootpwd' \
-e MYSQL_USER='keeper://YrXVDkmvSvQp_r4w4MmVLw/field/login' \
-e MYSQL_PASSWORD='keeper://YrXVDkmvSvQp_r4w4MmVLw/field/password' \
-e MYSQL_DATABASE='mydb' \
-p 3306:3306 \
--rm \
-it d1
