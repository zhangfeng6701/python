#!/bin/sh

#数据库环境变量
export ORACLE_BASE=/soft/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1
PATH=.:${PATH}:$HOME/bin:$ORACLE_HOME/bin

LOGIN=sunsc/sun99@179.169.13.71:1522/sunsc

cd /home/weblogic/result/T_result/backup
par_date=`echo "set head off;
select max(cs.bsnsdt) from com_stac cs where cs.vlidtg = '1';
exit" | sqlplus -s ${LOGIN}`
par_date=`echo $par_date |sed 's/ //g'`


rm -r *${par_date}*.txt
