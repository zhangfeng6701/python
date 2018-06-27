#!/bin/sh

export ORACLE_BASE=/soft/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1
PATH=.:${PATH}:$HOME/bin:$ORACLE_HOME/bin
LOGIN=suntx/sun99@179.169.13.210:1521/sunsc

cd /home/weblogic/impdata/impdata_Y/

par_date=`echo "set head off;
select max(cs.bsnsdt) from com_stac cs where cs.vlidtg = '1';
exit" | sqlplus -s ${LOGIN}`
par_date=`echo $par_date |sed 's/ //g'` 

date=$par_date

ftp -n -i  179.169.13.180<<EOF
user ygz ygz
passive
cd /home/ygz/impdata 
mget *${par_date}*

quit
EOF

for filenm in /home/weblogic/impdata/impdata_Y/* 
   do
     flnm=${filenm##*/}
     echo $flnm
     TARGET_FILE=`find /home/weblogic/impdata -maxdepth 1 -name "$flnm" | wc -l`
     echo $TARGET_FILE

     if [[ "$TARGET_FILE" -eq 0  ]] && [[ $filenm =~ $date  ]] ;then
        mv $flnm /home/weblogic/impdata
     fi
    done
