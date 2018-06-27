#!/bin/sh

name=ygz
type=full
random=$RANDOM
dt=$(date +%Y%m%d%H%M)
tgzFile=$name.ygz.$type.$dt.$random.tar.gz

source /home/oracle/.bash_profile

mkdir /home/backup/$dt
chmod -R 777 /home/backup/$dt
echo > /home/backup/nohup.out

/oradata/product/11g/db_1/bin/rman target / log=/home/backup/nohup.out <<EOF
run {
allocate channel d1 type disk;
backup as compressed backupset incremental level 0 database format '/home/backup/$dt/level0_%d_%T_%t_%U.bak' tag='level 0';
sql 'alter system archive log current';
sql 'alter system archive log current';
sql 'alter system archive log current';
backup archivelog all format '/home/backup/$dt/arch_%d_%T_%t_%U.bak';
backup spfile format '/home/backup/$dt/spfile_%d_%T_%s_%p_%U.bak';
backup current controlfile format '/home/backup/$dt/controlfile_%d_%T_%t_%U.bak';
crosscheck archivelog all;
delete noprompt archivelog until time='sysdate-1';
release channel d1;
}
EOF

cp /home/backup/nohup.out /home/backup/$dt/ygz_rman_log_$dt
chmod -R 777 $dt
tar czvf /home/backup/$tgzFile /home/backup/$dt
rm -rf /home/backup/$dt

md5sum -b /home/backup/$tgzFile >> /home/backup/md5.lst

find /home/backup/ -name "*tar.gz" -mtime +30 -exec rm -f {} \;

echo > /home/backup/ftp.log
ftp -ivn << EOF >> /home/backup/ftp.log 2>&1
open 172.168.99.230
user backup 1q2w3e4R
bin
put /home/backup/$tgzFile /backup/DB/$name/$tgzFile
asc
put /home/backup/md5.lst /backup/DB/$name/md5.lst
bye
EOF
