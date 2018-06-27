#!/bin/sh

#source /home/oracle/.bash_profile
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

file_name=`echo "set head off;
select substr(t.filenm,instr(t.filenm,'_',-1)+1) from com_edct t where t.status=1 and t.procna like '%DayEndCheckingBWProcesser_jzbank';
exit" | sqlplus -s ${LOGIN}`
file_name=`echo $file_name |sed 's/ //g'`

FTP_USR=xhx
FTP_PWD=xhx
PUT_PATH="/vdc1/xhx/ftp/FLBZ/${par_date}"
ftp -n -i  179.169.13.21<<EOF
user xhx xhx

cd $PUT_PATH
mget *.txt
quit
EOF

#mv /home/weblogic/ftpfile/501200*.txt ending_501200*.txt YGZ*  /home/weblogic/ftpfile/backu

FILE_LEN=`find /home/weblogic/result/T_result -maxdepth 1 -name "RTN_*" | wc -l`
echo $FILE_LEN

if [[ "$FILE_LEN" -gt 0 ]];then
for filenm in /home/weblogic/result/T_result/*;do
echo $filenm
flnm=${filenm##*/}
echo $flnm
TARGET_FILE=`find /home/weblogic/result/T_result/backup -maxdepth 1 -name "$flnm" | wc -l`
echo $TARGET_FILE

if [[ $flnm =~ "RTN_501200" ]] && [[ $flnm =~ ${file_name} ]] && [[ $TARGET_FILE -eq 0 ]] && [[ ! $flnm =~ '9999' ]];then
mv $filenm /home/weblogic/result/T_result/backup
fi
if [[ $flnm =~ "RTN_ending_501200" ]] && [[ $flnm =~ ${file_name} ]] && [[ $TARGET_FILE -eq 0 ]] && [[ ! $flnm =~ '9999' ]];then
mv $filenm /home/weblogic/result/T_result/backup
fi
done
fi

rm -r /home/weblogic/result/T_result/*.txt 
