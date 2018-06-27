#!/bin/sh
#source /home/oracle/.bash_profile

export ORACLE_BASE=/soft/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1
PATH=.:${PATH}:$HOME/bin:$ORACLE_HOME/bin
LOGIN=sunsc/sun99@179.169.13.71:1522/sunsc
echo "sh fileControll.sh::::stat::::::"
echo "set up parameters::::1"	
base_dir="/home/weblogic/impdata2"

#获取当前的业务日期
par_date=`echo "set head off;
select max(cs.bsnsdt) from com_stac cs where cs.vlidtg = '1';
exit" | sqlplus -s ${LOGIN}`
par_date=`echo $par_date |sed 's/ //g'` 

is_exist=`echo "set head off;
select count(1) from glo_imdt where bathid=${par_date} and plancd='glivhcr';
exit" | sqlplus -s ${LOGIN}` 
echo "obite file::::::::2"
cd /home/weblogic/SSZZ/Y_file

if [$is_exist -eq 0 ];then
insert_jl=`echo "set head off;
INSERT INTO GLO_IMDT (STACID, SOURST, SOURDT,
      ACCTBR, BATHID, USERCD, BRCHCD, STATUS, NEXTDT, CURRDT, SWITDT, PLANCD, DATACH, TYPECD) 
      VALUES ('3','01',${par_date},'',${par_date},'****','****',4,'','','','glivhcr','glivchr','1');
              COMMIT;
exit" | sqlplus -s ${LOGIN}` 
fi

cd ${base_dir}

bool=0
time_count=10
while true
do

echo "等待并获取文件1小时开始::::::::::::::::::::::;start::::::::::::::::"
ftp -n -i  179.169.13.21<<EOF
user ygz ygz

cd /vdc1/ygz/simpdata
mget *$par_date*.txt
quit
EOF

for filenm in /home/weblogic/SSZZ/Y_file/*.txt
  do
     flnm=${filenm##*/}
     echo $flnm
     TARGET_FILE=`find /home/weblogic/impdata2 -maxdepth 1 -name "$flnm" | wc -l`
     echo $TARGET_FILE
     if [[ "$TARGET_FILE" -eq 0  ]] && [[ $filenm =~ $date  ]] ;then
     mv $flnm /home/weblogic/impdata2
     fi
  done

FILE_LEN=`find ${base_dir} -maxdepth 1 -name gliVchr_${par_date}_* | wc -l`
echo "路径下gliVchr_${par_date}_*开头的个数为"$FILE_LEN
FILE_OK=`find ${base_dir} -maxdepth 1 -name ${par_date}_ok.txt | wc -l`
echo "标识文件${par_date}_ok.txt的个数为"$FILE_OK
if  [ $FILE_LEN -eq 5 ] && [ $FILE_OK -eq 1 ];then
    bool=1
	echo "文件获取完成::::::::::::end::::::::::::::::::"
	break
else
    echo "1:"$bool
    time_count=$((time_count-1))
    sleep 60
fi
if [ time_count -eq 0 ];then
   echo "等待获取文件1小数时间结束！"
   break
fi
done

if [ $bool -eq 1 ] ;then
echo "file obite success::::start  do deal file :::::::3"
#刷新字典到缓存中
java -jar /home/weblogic/SSZZ/refleshDictData.jar /home/weblogic/SSZZ
java -jar /home/weblogic/SSZZ/refleshSysData.jar /home/weblogic/SSZZ
echo "刷新完成"

cd ${base_dir}

#新一轮调度开始之前进行状态的准备
updt_stat=`echo "set head off;
update com_stac a set a.stacst = 20;
UPDATE COM_EDCT A SET A.PROCTG = '0' WHERE A.STACID = '3';
delete from glo_imdt where bathid=${par_date} and plancd='glivhcr';
delete from glo_imdt where bathid=${par_date} and plancd='txaVchr';
delete from vats_data_ready where data_dt=${par_date};
commit;
exit" | sqlplus -s ${LOGIN}` 

echo "调度准备状态完成"
sh /home/weblogic/SSZZ/callVATS.sh
else
echo "fileControll文件未完全收到，错误退出"
exit 1
fi
echo "fileControll脚本执行完成"
