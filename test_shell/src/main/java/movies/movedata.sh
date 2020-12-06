#!/bin/sh
#line="\r\n"
#使用bash做为默认shell 
cd /usr/local/sbin

ReadINIfile()
  { 
  INIFILE=$1
  SECTION=$2
  ITEM=$3
  ReadINI=`awk -F '=' '/\['$SECTION'\]/{a=1}a==1&&$1~/'$ITEM'/{print $2;exit}' $INIFILE`
  value=$ReadINI
}

list_alldir(){ 
  for file in  $1/*
  do
    if [ -d $file ]; then
     # echo $file
#	continue
      #list_alldir $file #在这里递归调用
        ReadINIfile config.ini source path
        name=$value
        endchar=${name##*/}
        if [ $endchar != "/" ]; then
          name=${name}/
        fi  
        plandir=${file#*${name}}
        # 判断plandir的长度,不是32的不处理
        if [ $plandir -ne 32 ]
        then
            continue
        fi
        sqlstr="select distinct plan_id from trial where judge_process>=3 and plan_id="
        sqlstr=${sqlstr}\'${plandir}\'";"
        rm -rf /usr/local/movies/trial.cfg
        /usr/bin/mysql -uroot -pdcs2011 dcs -e "${sqlstr}" > /usr/local/movies/trial.cfg
          while read plan_id;
          do
            if [ "$plan_id"x = ""x ]; 
            then
              break
            else
              if [ "$plan_id"x = "planid"x ];
              then
                continue
              else
                if  [ "$plan_id"x = "$plandir"x ];
                then
                  ReadINIfile config.ini source destlist
									destlist=$value
                  max=0
                  maxpath=""
                  for i in $destlist
                  do
                    ReadINIfile config.ini dest $i
                    df=$(df -m |grep $value |awk '{print $4}')
                    S="$df"
                    echo $S | grep " " >/dev/null 2>&1
                    if [ $? = 0 ];then        
                       df=$(echo $S | awk '{print $1}')
                    fi
                    if [ $max = 0 ];
                    then
                    	max=$df
                      maxpath=$value
                    else
                      if [ $df -le $max ];
                      then
                      	max=$df
                        maxpath=$value
                      fi
                    fi
                  done               
                  path=$maxpath
                  endchar=${path##*/}
                  if [ $endchar != "/" ]; then
                  	path1=${path}/${plandir}
                  else
                    path1=${path}${plandir}	
                  fi  
                  if ! [ -e $path ]; then
                     mkdir -m 777 -p $path1
                  fi
		  if [ ! -d "${path1}" ]; then
		  	echo "${path1} not exist start mv..."
                  	mv -f ${file} ${path}
		  else
		  	echo "${path1} exist start rm -f..."
			#rm -rf ${file}
		  fi
                  chmod -R 777 ${path}
                  diffdir=${path1#*${name}}
                  #echo $diffdir
                  
                  sqlstr="update trial set courtrec=replace (courtrec,"
                  sqlstr=${sqlstr}\'${plandir}\'
                  sqlstr=${sqlstr}","\'${diffdir}\'
                  sqlstr=${sqlstr}") where plan_ID="
                  sqlstr=${sqlstr}\'${plandir}\'";"
                  #echo $sqlstr
                  /usr/bin/mysql -uroot -pdcs2011 dcs -e "${sqlstr}"
                  sqlstr="update recordinfo set filename=replace (filename,"
                  sqlstr=${sqlstr}\'${plandir}\'
                  sqlstr=${sqlstr}","\'${diffdir}\'
                  sqlstr=${sqlstr}") where plan_ID="
                  sqlstr=${sqlstr}\'${plandir}\'";"
                  /usr/bin/mysql -uroot -pdcs2011 dcs -e "${sqlstr}"
                  #echo $sqlstr
                  dir=${diffdir%%/*}
                  #echo $dir
                  sqlstr="update recordinfo set filename=replace (filename,"
                  sqlstr=${sqlstr}\'${dir}/${dir}\'
                  sqlstr=${sqlstr}","\'${dir}\'");"
                  /usr/bin/mysql -uroot -pdcs2011 dcs -e "${sqlstr}"
                  #echo sqlstr
                  sqlstr="update trial set courtrec=replace (courtrec,"
                  sqlstr=${sqlstr}\'${dir}/${dir}\'
                  sqlstr=${sqlstr}","\'${dir}\'");"
                  /usr/bin/mysql -uroot -pdcs2011 dcs -e "${sqlstr}"
                  #echo $sqlstr
                fi
              fi
            fi  
          done < /usr/local/movies/trial.cfg 
    fi
  done
}

value=""
ReadINIfile config.ini source path
INIT_PATH=${value}
list_alldir $INIT_PATH
