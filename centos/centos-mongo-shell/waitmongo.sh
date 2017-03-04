#!/bin/bash

for addr in "$*"
do
	echo $addr
	i=0
	dbstatus=-1
	while [ $i -lt 10 ] && [ $dbstatus -ne 0 ] ; do
		# echo $i
		/opt/mongo-source/mongodb-2.6.9/bin/mongo $addr/admin --eval "JSON.stringify(db.stats())" >> /opt/shell/waitmongo.log
		dbstatus=$?
		sleep 2s
		let i++
	done
	if [ $i -eq 10 ]; then
		echo "timeout 20s waiting for" $addr
	else
		sleep 2s # make sure mongo service is up
		echo "mongodb is up"
	fi
done

# result=$(/opt/mongo-source/mongodb-2.6.9/bin/mongo 127.0.0.1:7000 --eval "JSON.stringify(db.stats())")