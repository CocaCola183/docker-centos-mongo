#!/bin/bash

# 配置信息
SHARD1_RS_NAME="shard1"
SHARD1_MASTER_ADDRESS="127.0.0.1:7000"
SHARD1_SECONDARY_ADDRESS="127.0.0.1:7001"
SHARD1_ARBIT_ADDRESS="127.0.0.1:6000"

SHARD2_RS_NAME="shard2"
SHARD2_MASTER_ADDRESS="127.0.0.1:7002"
SHARD2_SECONDARY_ADDRESS="127.0.0.1:7003"
SHARD2_ARBIT_ADDRESS="127.0.0.1:6001"

SHARD3_RS_NAME="shard3"
SHARD3_MASTER_ADDRESS="127.0.0.1:7004"
SHARD3_SECONDARY_ADDRESS="127.0.0.1:7005"
SHARD3_ARBIT_ADDRESS="127.0.0.1:6002"

CONFIG1_ADDRESS="127.0.0.1:8000"
CONFIG2_ADDRESS="127.0.0.1:8001"
CONFIG3_ADDRESS="127.0.0.1:8002"

MONGOS1_ADDRESS="127.0.0.1:9000"
MONGOS2_ADDRESS="127.0.0.1:9001"

# 启动并配置分片1
nohup /opt/mongo-source/mongodb-2.6.9/bin/mongod -f /data/mongod-1-1/mongo.conf &
waitmongo $SHARD1_MASTER_ADDRESS

nohup /opt/mongo-source/mongodb-2.6.9/bin/mongod -f /data/mongod-1-2/mongo.conf &
waitmongo $SHARD1_SECONDARY_ADDRESS

nohup /opt/mongo-source/mongodb-2.6.9/bin/mongod -f /data/mongod-1-3/mongo.conf &
waitmongo $SHARD1_ARBIT_ADDRESS

/opt/mongo-source/mongodb-2.6.9/bin/mongo \
$SHARD1_MASTER_ADDRESS/admin \
--eval "rs.initiate({\"_id\": \"$SHARD1_RS_NAME\", \"members\": [{\"_id\": 0, \"host\": \"$SHARD1_MASTER_ADDRESS\"}]});"

/opt/mongo-source/mongodb-2.6.9/bin/mongo \
$SHARD1_MASTER_ADDRESS/admin \
--eval "rs.add(\"$SHARD1_SECONDARY_ADDRESS\");"

/opt/mongo-source/mongodb-2.6.9/bin/mongo \
$SHARD1_MASTER_ADDRESS/admin \
--eval "rs.addArb(\"$SHARD1_ARBIT_ADDRESS\");"

# /opt/mongo-source/mongodb-2.6.9/bin/mongo 127.0.0.1:7001/admin

# 启动并配置分片2
nohup /opt/mongo-source/mongodb-2.6.9/bin/mongod -f /data/mongod-2-1/mongo.conf &
waitmongo $SHARD2_MASTER_ADDRESS

nohup /opt/mongo-source/mongodb-2.6.9/bin/mongod -f /data/mongod-2-2/mongo.conf &
waitmongo $SHARD2_SECONDARY_ADDRESS

nohup /opt/mongo-source/mongodb-2.6.9/bin/mongod -f /data/mongod-2-3/mongo.conf &
waitmongo $SHARD2_ARBIT_ADDRESS

/opt/mongo-source/mongodb-2.6.9/bin/mongo \
$SHARD2_MASTER_ADDRESS/admin \
--eval "rs.initiate({\"_id\": \"$SHARD2_RS_NAME\", \"members\": [{\"_id\": 0, \"host\": \"$SHARD2_MASTER_ADDRESS\"}]});"

/opt/mongo-source/mongodb-2.6.9/bin/mongo \
$SHARD2_MASTER_ADDRESS/admin \
--eval "rs.add(\"$SHARD2_SECONDARY_ADDRESS\");"

/opt/mongo-source/mongodb-2.6.9/bin/mongo \
$SHARD2_MASTER_ADDRESS/admin \
--eval "rs.addArb(\"$SHARD2_ARBIT_ADDRESS\");"

# /opt/mongo-source/mongodb-2.6.9/bin/mongo 127.0.0.1:7003/admin

# 启动并配置分片3
nohup /opt/mongo-source/mongodb-2.6.9/bin/mongod -f /data/mongod-3-1/mongo.conf &
waitmongo $SHARD3_MASTER_ADDRESS

nohup /opt/mongo-source/mongodb-2.6.9/bin/mongod -f /data/mongod-3-2/mongo.conf &
waitmongo $SHARD3_SECONDARY_ADDRESS

nohup /opt/mongo-source/mongodb-2.6.9/bin/mongod -f /data/mongod-3-3/mongo.conf &
waitmongo $SHARD3_ARBIT_ADDRESS

/opt/mongo-source/mongodb-2.6.9/bin/mongo \
$SHARD3_MASTER_ADDRESS/admin \
--eval "rs.initiate({\"_id\": \"$SHARD3_RS_NAME\", \"members\": [{\"_id\": 0, \"host\": \"$SHARD3_MASTER_ADDRESS\"}]});"

/opt/mongo-source/mongodb-2.6.9/bin/mongo \
$SHARD3_MASTER_ADDRESS/admin \
--eval "rs.add(\"$SHARD3_SECONDARY_ADDRESS\");"

/opt/mongo-source/mongodb-2.6.9/bin/mongo \
$SHARD3_MASTER_ADDRESS/admin \
--eval "rs.addArb(\"$SHARD3_ARBIT_ADDRESS\");"

# /opt/mongo-source/mongodb-2.6.9/bin/mongo 127.0.0.1:7005/admin

# 启动配置节点
nohup /opt/mongo-source/mongodb-2.6.9/bin/mongod -f /data/config-1/mongo.conf &
waitmongo $CONFIG1_ADDRESS
# tail -f /mongodb/config-1/log/mongo.log
 
nohup /opt/mongo-source/mongodb-2.6.9/bin/mongod -f /data/config-2/mongo.conf &
waitmongo $CONFIG2_ADDRESS
# tail -f /mongodb/config-2/log/mongo.log

nohup /opt/mongo-source/mongodb-2.6.9/bin/mongod -f /data/config-3/mongo.conf &
waitmongo $CONFIG3_ADDRESS
# tail -f /mongodb/config-3/log/mongo.log

# 启动并配置mongos
 
# # 启动并配置mongos_1
nohup /opt/mongo-source/mongodb-2.6.9/bin/mongos -f /data/mongos-1/mongo.conf &
waitmongo $MONGOS1_ADDRESS


/opt/mongo-source/mongodb-2.6.9/bin/mongo \
$MONGOS1_ADDRESS/admin \
--eval "db.runCommand({\"addshard\": \"shard1/$SHARD1_MASTER_ADDRESS,$SHARD1_SECONDARY_ADDRESS\"});"

/opt/mongo-source/mongodb-2.6.9/bin/mongo \
$MONGOS1_ADDRESS/admin \
--eval "db.runCommand({\"addshard\": \"shard2/$SHARD2_MASTER_ADDRESS,$SHARD2_SECONDARY_ADDRESS\"});"

/opt/mongo-source/mongodb-2.6.9/bin/mongo \
$MONGOS1_ADDRESS/admin \
--eval "db.runCommand({\"addshard\": \"shard3/$SHARD3_MASTER_ADDRESS,$SHARD3_SECONDARY_ADDRESS\"});"

# /opt/mongo-source/mongodb-2.6.9/bin/mongo 127.0.0.1:9000

# # 启动并配置mongos_2
nohup /opt/mongo-source/mongodb-2.6.9/bin/mongos -f /data/mongos-2/mongo.conf &
waitmongo $MONGOS2_ADDRESS

/opt/mongo-source/mongodb-2.6.9/bin/mongo \
$MONGOS2_ADDRESS/admin \
--eval "db.runCommand({\"addshard\": \"shard1/$SHARD1_MASTER_ADDRESS,$SHARD1_SECONDARY_ADDRESS\"});"

/opt/mongo-source/mongodb-2.6.9/bin/mongo \
$MONGOS2_ADDRESS/admin \
--eval "db.runCommand({\"addshard\": \"shard2/$SHARD2_MASTER_ADDRESS,$SHARD2_SECONDARY_ADDRESS\"});"

/opt/mongo-source/mongodb-2.6.9/bin/mongo \
$MONGOS2_ADDRESS/admin \
--eval "db.runCommand({\"addshard\": \"shard3/$SHARD3_MASTER_ADDRESS,$SHARD3_SECONDARY_ADDRESS\"});"
