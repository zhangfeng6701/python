#!/bin/sh

#source /home/oracle/.bash_profile
#./root/.bashrc
export ORACLE_BASE=/soft/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1

export JAVA_HOME=/opt/jdk1.7.0_79
export PATH=$PATH:$JAVA_HOME/bin
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar

PATH=.:${PATH}:$HOME/bin:$ORACLE_HOME/bin
LOGIN=suntx/sun99@179.169.13.210:1521/sunsc

count=2000
par_date=`echo "set head off;
select max(cs.bsnsdt) from com_stac cs where cs.vlidtg = '1';
exit" | sqlplus -s ${LOGIN}` 
#能输出日期
#echo ${par_date}
cd /home/weblogic/dayend_shell/log
logDir=$par_date
#echo ${logDir}
#路径确认无误
#echo ${logDir}
logFile=DAYEND_PROCESS_VATS.log
due_time=0900
#如果目录不存在，创建文件夹
[ -d ${logDir} ] || `mkdir -p ${logDir}`

echo "" | tee -a ${logDir}/${logFile}
echo "==============================[ `date +\"%Y-%m-%d %T\"` ]==============================" | tee -a ${logDir}/${logFile}
echo "today's trandt is " | tee -a ${logDir}/${logFile}
echo ${par_date} | tee -a ${logDir}/${logFile}


while [ $count -gt 0 ]
do
ln_count=`echo "set head off;
select count(*) from glo_imdt gi where gi.bathid= ${par_date} and gi.plancd='glivhcr';
exit" | sqlplus -s ${LOGIN}` 
echo $ln_count
# 如果存在与当前业务日期一致的数，跳出循环，进行下一个步骤
if [ ${ln_count} = '1' ] ; then
  echo "ok" | tee -a ${logDir}/${logFile}
  break
else
  echo "The data did not finish successfully${ln_count}" | tee -a ${logDir}/${logFile}
fi

count=`expr $count - 1`
echo "等待剩余--$count 次" | tee -a ${logDir}/${logFile}
sleep 20

done

if [ ${ln_count} = '1' ] ; then
echo "Begin to process dayend !" | tee -a ${logDir}/${logFile}

java -jar /home/weblogic/dayend_shell/simulationLogin.jar | tee -a ${logDir}/${logFile}

grep "DayEnd startup failed,Please contact the administrator" /home/weblogic/dayend_shell/log/$logDir/${logFile} > /dev/null

if [ $? -eq 0 ] 
then
	echo "" | tee -a ${logDir}/${logFile}
	echo "" > ${logDir}/${logFile}
        echo "start Dayend process job error !" | tee -a ${logDir}/${logFile}
	exit 1
fi
else
echo "数据未准备好!请检查!" | tee -a ${logDir}/${logFile}
exit 1
fi

cd /home/weblogic/dayend_shell/log 

echo "" | tee -a ${logDir}/${logFile}
echo "[ PLSQL run at `date +\"%Y-%m-%d %T\"` ]" | tee -a ${logDir}/${logFile}

cd /home/weblogic/dayend_shell/

while true
do

#如果日终步骤有错，那么跳出循环
ret1=`echo "set head off;
SELECT COUNT(1) OUT FROM COM_EDCT WHERE PROCTG = '2' AND STATUS = '1';	
exit" | sqlplus -s ${LOGIN}` 

cd /home/weblogic/dayend_shell/log
echo "ret1:"|tee -a ${logDir}/${logFile}
echo $ret1|tee -a ${logDir}/${logFile}

if [ ${ret1} -gt 0 ]
then
     echo "" | tee -a ${logDir}/${logFile}
     echo "Dayend process job have some errors !" | tee -a ${logDir}/${logFile}
 
exit 1
fi	
#cd /home/oracle/dayend_shell/	
#如果传票流水表有未执行完的，退出循环
ret2=`echo "set head off;
 SELECT COUNT(1) OUT FROM GLI_VCHR WHERE dealst = '0' and trandt = ${par_date};
exit" | sqlplus -s ${LOGIN}` 
cd /home/weblogic/dayend_shell/log      
echo "ret2:"|tee -a ${logDir}/${logFile}
echo $ret2|tee -a ${logDir}/${logFile}

if [ ${ret2} -gt 0 ]
then
     echo "" | tee -a ${logDir}/${logFile}
     echo "GLI_VCHR have some  data(dealst = 0) not finish yet !" | tee -a ${logDir}/${logFile}
#exit 1
fi
#cd /home/oracle/dayend_shell/
#如果能获取到VATS_DATA_READY里面的当前业务日期，退出日终
ret=`echo "set head off;
SELECT count(1) OUT FROM VATS_DATA_READY WHERE DATA_DT=${par_date};
exit" | sqlplus -s ${LOGIN}` 
#echo $ret
cd /home/weblogic/dayend_shell/log/
echo "ret:"|tee -a ${logDir}/${logFile}
echo $ret|tee -a ${logDir}/${logFile}

now_time=`date +"%H%M"`

if [ ${ret} -eq 1 ]
then
     echo "" | tee -a ${logDir}/${logFile}
     echo "====Day end over time=======[ `date +\"%Y-%m-%d %T\"` ]============" | tee -a ${logDir}/${logFile}
     echo "Dayend process job have succeeded !" | tee -a ${logDir}/${logFile}
exit 0
else
        if [ $now_time -ge $due_time ]
        then
              echo "VATS are not ready and now time [ `date +"%H:%M"` ] is over 09:00 !" | tee -a ${logDir}/${logFile}
              echo "" | tee -a ${logDir}/${logFile}
              echo "==========[ `date +\"%Y-%m-%d %T\"` ]==========" | tee -a ${logDir}/${logFile}
              exit 19
        else
              echo "" | tee -a ${logDir}/${logFile}
              echo " dayend process job have not finished  !!!" | tee -a ${logDir}/${logFile}
              sleep 20
        fi
fi
done
