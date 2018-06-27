#!/bin/sh

#source /soft/u01/app/oracle/.bash_profile
#数据库环境变量
export ORACLE_BASE=/soft/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1
PATH=.:${PATH}:$HOME/bin:$ORACLE_HOME/bin
LOGIN=sunsc/sun99@179.169.13.71:1522/sunsc
FILE_LEN=`find /home/weblogic/ftpfile -maxdepth 1 -name "YGZ_KJYQ*"  | wc -l`
echo $FILE_LEN
cd /home/weblogic/fify

if [ "$FILE_LEN" -gt 0 ];then

par_date=`echo "set head off;
select max(cs.bsnsdt) from com_stac cs where cs.vlidtg = '1';
exit" | sqlplus -s ${LOGIN}`
par_date=`echo $par_date |sed 's/ //g'` 

FTP_USR=xhx
FTP_PWD=xhx
PUT_PATH="/vdc1/xhx/ftp/FLBZ/${par_date}"
echo $PUT_PATH
ftp -n -i  179.169.13.21<<EOF
user xhx xhx
passive
if [ ! -d $PUT_PATH ];then
mkdir $PUT_PATH
fi

cd $PUT_PATH 

mput 501200*.txt
mput ending_501200*.txt
mput YGZ*.ok
mput YGZ*.txt
quit
EOF

mv /home/weblogic/fify/501200*.txt ending_501200*.txt YGZ*  /home/weblogic/fify/backup

fi
