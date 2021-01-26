#!/bin/bash
#根据录像文件插入未入库的视频文件
#先判断当前的系统centos7 ubuntn  centos7.6
exec  9>&2  8>&1
mkdir -p /home/hxht/logs/inert_recordinfo_by_movies
exec &>/home/hxht/logs/inert_recordinfo_by_movies/inert_recordinfo_by_movies.log
password=dcs2011
mysql_url=/usr/bin/mysql
#判断当前数据库地址
if [ ! -d $mysql_url ]
then
    mysql_url=/usr/bin/mysql
fi
echo "当前数据库地址mysql_url:$mysql_url"
#获取服务器ip-court表
ip_sql="select  centerip from court"
ip=$($mysql_url -uroot -p$password dcs -e "$ip_sql"|sed -n 2p|awk '{print $1}')
echo "当前服务器ip:$ip"
for i in $(ls  /usr/local/movies)
do
    length=${#i}
    if [ $length -eq 32 ]
    then
          echo "filename=$i"
          sql="select count(*) from recordinfo where plan_id=\"$i\"  limit 0,1"
          count=$($mysql_url -uroot -p$password -h$ip dcs -e "$sql"|grep -E "0|1")
          #count=$($mysql_url -uroot -p$password dcs -e "$sql"|sed -n 2p|awk '{print $1}')
          echo "count=$count"
          if [ $count -eq 0 ]
          then
              echo "plan_id=$i is not insert recordinfo"
              #更新笔录ftp://154.128.8.118/dd74ac0d8f8f404194ec7bdc06834f3e/TheRecord_new.doc
              sql_trial="update trial set courtrec=\"ftp://$ip/$i/TheRecord_new.doc\" where plan_id='$i'"
              $mysql_url -uroot -p$password -h$ip dcs -e "$sql_trial"
              #生成32位随机数
               #uid=$(/dev/urandom | tr -dc 'a-z0-9' | fold -w 32 | head -n1)
               sql_case_id="select case_id from plan where uid='$i'"
               case_id=$($mysql_url -uroot -p$password -h$ip dcs -e "$sql_case_id"|sed -n 2p|awk '{print $1}')
               #处理视频文件,生成sql, 批处理
               #查找出目录文件
               #排期号的下一级目录
               for name in $(ls  /usr/local/movies/$i)
               do
                    if [ -d /usr/local/movies/$i/$name ]
                    then
                        echo "macth ok name=$name"
                        #获取间接值
                        movies_file=${name}
                        break;

                    fi
               done
               echo "movies_file=$movies_file"
               #只查找mp4结尾的文件
               for video in $(ls  /usr/local/movies/$i/$movies_file|grep -E ".mp4$")
               do
                   echo "change video=$video"
                    uid=$(cat /dev/urandom|od -x|head -1|cut -d" " -f2-|tr -d " "|fold -w 32)
                   filename=$i/$movies_file/$video
                   if [[ $filename =~ "_4.mp4" ]]
                    then
                        chn=4
                        channelsname="证据图像"
                    fi
                    if [[ $filename =~ "_2.mp4" ]]
                    then
                          chn=2
                          channelsname="合成图像"
                    fi

                     if [[ $filename =~ "_1.mp4" ]]
                    then
                          chn=1
                          channelsname="合成图像"
                    fi

                    if [[ $filename =~ "_1.mp4" ]]|| [[ $filename =~ "_4.mp4" ]]|| [[ $filename =~ "_2.mp4" ]]
                     then
                        insert_sql="insert into recordinfo(uid,plan_id,case_id,chn,channelsname,filename,url)values(\"$uid\",\"$i\",\"$case_id\",1,\"$channelsname\",\"$filename\",\"$ip\")"
                        echo "insert_sql=$insert_sql"
                        $mysql_url -uroot -p$password -h$ip dcs -e  "$insert_sql"
                     fi
                done
                #更新plan trial两表状态
                update_plan="update plan set status=3 where uid=\"$i\" and status=0"
                update_trial="update trial set judge_process=3 where plan_id=\"$i\" and judge_process=0"
                $mysql_url -uroot -p$password -h$ip dcs -e "$update_plan"
                $mysql_url -uroot -p$password -h$ip dcs -e "$update_trial"
          fi

    fi

done
exec 1>&8 2>&9
