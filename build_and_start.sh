docker rm ozone_singleton_multi_dn && docker rmi ozone_multi_dns:duyuqi
sleep 2
docker build -t ozone_multi_dns:duyuqi -f Dockerfile.multidn .
sleep 1
docker run -t -d --network=host -p 9879:9878 -p 9877:9876 --name ozone_singleton_multi_dn ozone_multi_dns:duyuqi