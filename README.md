Yentend Docker Image
=====================================

https://conan-equal-newone.github.io/yenten/

Build
-------

```
git clone https://github.com/bauzer/docker-yentend.git
cd docker-yentend
docker build -t docker-yentend .
```

Setup
-------

### docker gataway address

```
ip addr show dev docker0
```

### edit conf/yenten.conf

```
# RPC user name
rpcuser=user
# RPC password
rpcpassword=password
# enable RPC
server=1
# allow ip(docker gateway address)
rpcallowip=172.17.0.1
# RPC port
rpcport=9982
```

Run
-------

```
docker run -d -v $(pwd)/conf/:/home/yenten/.yenten/ \
  -p 9982:9982 docker-yentend
```

License
-------

Yentend Docker Image is released under the terms of the MIT license.
