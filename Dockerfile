FROM centos


# 1.安装基本依赖
RUN yum update -y && yum install epel-release -y && yum update -y && yum install wget psmisc  unzip epel-release  xz gcc-c++ make automake zlib-devel openssl-devel git nodejs golang supervisor -y

#2. 编译安装bk-cmdb
ENV GOPATH=/data/abc
RUN mkdir -p /data/abc/src
WORKDIR /data/abc/src/
RUN git clone -b v3.0.7-beta https://github.com/Tencent/bk-cmdb.git configcenter
WORKDIR configcenter/src/
RUN make 


#3. 初始化bk-cmdb


WORKDIR bin/build/18.06.22/

ENV ZOOKEEPER_ADDR=192.168.0.164:2181 \
    DATABASE_NAME=cmdb \
    REDIS_IP=192.168.0.164 \
    REDIS_PORT=6379 \
    REDIS_PASSWD=cmdb \
    MONGO_IP=192.168.0.164 \
    MONGO_PORT=27017 \
    MONGO_USER=cc \
    MONGO_PASSWD=cc \
    BLUEKING_CMDB_URL="http://127.0.0.1:8083" \
    LISTEN_PORT=8083

RUN python init.py --discovery $ZOOKEEPER_ADDR \
                    --database $DATABASE_NAME \
                    --redis_ip $REDIS_IP \
                    --redis_port $REDIS_PORT \
                    --redis_pass $REDIS_PASSWD \
                    --mongo_ip $MONGO_IP \
                    --mongo_port $MONGO_PORT \
                    --mongo_user $MONGO_USER \
                    --mongo_pass $MONGO_PASSWD \
                    --blueking_cmdb_url $BLUEKING_CMDB_URL \
                    --listen_port $LISTEN_PORT



#4.初始化mongodb(需要先启动服务，才能去初始化)

#RUN  ./start.sh  && ./init_db.sh && ./stop.sh



#5.复制supervisor 配置文件，保证docker持续运行

COPY supervisord.conf /etc/supervisord.conf
COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh 



ENV ZOOKEEPER_ADDR=192.168.0.164:2181 \
    DATABASE_NAME=cmdb \
    REDIS_IP=192.168.0.164 \
    REDIS_PORT=6379 \
    REDIS_PASSWD=cmdb \
    MONGO_IP=192.168.0.164 \
    MONGO_PORT=27017 \
    MONGO_USER=cc \
    MONGO_PASSWD=cc \
    BLUEKING_CMDB_URL="http://127.0.0.1:8083" \
    LISTEN_PORT=8083



EXPOSE 8083

ENTRYPOINT ["entrypoint.sh"]