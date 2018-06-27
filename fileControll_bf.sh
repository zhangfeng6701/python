#!/bin/sh

#source /soft/u01/app/oracle/.bash_profile
#-----------shu ju ku pei zhi--------------------------------
export ORACLE_BASE=/soft/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1
PATH=.:${PATH}:$HOME/bin:$ORACLE_HOME/bin
LOGIN=suntx/sun99@179.169.13.210:1521/sunsc

#----------------sheng chang gai wei canshu chuang zhangwu riqi-----------------------



FILE_LEN=`find /home/weblogic/ftpfile -maxdepth 1 -name "YGZ_KJYQ*"  | wc -l`
echo $FILE_LEN
cd /home/weblogic/ftpfile

if [ "$FILE_LEN" -gt 0 ];then

par_date=`echo "set head off;
select max(cs.bsnsdt) from com_stac cs where cs.vlidtg = '1';
exit" | sqlplus -s ${LOGIN}`
par_date=`echo $par_date |sed 's/ //g'` 

#par_date=$1

FTP_USR=xhx
FTP_PWD=xhx
PUT_PATH="/home/xhx/ftp/FLBZ/${par_date}"
PUT_ZPATH="/home/xhx/ftp/ZZBZ/${par_date}"
echo $PUT_PATH
ftp -n -i  179.169.13.180<<EOF
user xhx xhx

if [ ! -d $PUT_PATH ];then
mkdir $PUT_PATH
fi

cd $PUT_PATH 

mput 501200*.txt
mput ending_501200*.txt

if [! -d $PUT_ZPATH ]; then
mkdir $PUT_ZPATH
fi
cd $PUT_ZPATH
mput YGZ$par_date.ok
mput YGZ$par_date.txt
quit
EOF

mv /home/weblogic/ftpfile/501200*.txt ending_501200*.txt YGZ*  /home/weblogic/ftpfile/backup

fi
