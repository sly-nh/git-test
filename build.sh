#!/bin/bash
#/***************************************************************************
# *
# * copyright (c) 2019 ke.com, Inc. All Rights Reserved
# *
# **************************************************************************/

#/**
# * @file build.sh
# * @author dongxiaowen001@ke.com
# * @date 2019/04/01/ 15:33:13
# * @version $Revision: 1.0 $
# * @brief
# *
# **/


source $HOME/.bash_profile 1>/dev/null 2>/dev/null

CURRENT_PATH=`pwd`


LOG_FATAL=1
LOG_WARNING=2
LOG_NOTICE=4
LOG_TRACE=8
LOG_DEBUG=16
LOG_LEVEL_TEXT=(
    [1]="FATAL"
    [2]="WARNING"
    [4]="NOTICE"
    [8]="TRACE"
    [16]="DEBUG"
)

TTY_FATAL=1
TTY_PASS=2
TTY_TRACE=4
TTY_INFO=8
TTY_MODE_TEXT=(
    [1]="[FAIL ]"
    [2]="[PASS ]"
    [4]="[TRACE]"
    [8]=""
)

TTY_MODE_COLOR=(
    [1]="1;31"
    [2]="1;32"
    [4]="0;36"
    [8]="1;33"
)

#CONF_LOG_FILE="$(pwd)/_local_build.log"
CONF_LOG_FILE="$(pwd)/_build.log"

##! @BRIEF: print info to tty & log file
##! @IN[int]: $1 => tty mode
##! @IN[string]: $2 => message
##! @RETURN: 0 => sucess; 1 => failure
function Print()
{
    local tty_mode=$1
    local message="$2"

    local time=`date "+%m-%d %H:%M:%S"`
    echo "${LOG_LEVEL_TEXT[$log_level]}: $time: ${MODULE_NAME} * $$ $message" >> ${CONF_LOG_FILE}
    echo -e "\e[${TTY_MODE_COLOR[$tty_mode]}m${TTY_MODE_TEXT[$tty_mode]} ${message}\e[m"
    return $?
}

##! @BRIEF: run cmd if fail exit proc with errno
##! @IN[string]: $@
##! @RETURN: exit with errno
function verify_run()
{
    cmd=$@
    /bin/bash -c "$cmd"
    if [ $? -ne 0 ]
    then
        Print $LOG_FATAL "run cmd error: $cmd"
        exit 255
    else
        Print $LOG_NOTICE "run cmd succ: $cmd"
        return 0
    fi
}

##! @BRIEF: make
##! @RETURN:
make()
{
    verify_run "JAVA_HOME=$JAVA8_HOME ./gradlew build -PmavenUsername=inf -PmavenPassword=123qwe"
}

##! @BRIEF: unit test run
##! @RETURN:
unittest()
{
    mvn package
}

##! @BRIEF: module test run
##! @RETURN:
moduletest()
{
    return 0
}

sys_init()
{
    return 0
}


package_module()
{
    mkdir -p releases/{bin,config,lib,pid}
    #cp run.sh releases/bin/
    chmod +x setenv.sh && cp setenv.sh releases/bin/
    cp build/libs/*.jar releases/lib/
    mv releases/lib/guard-service-*.jar releases/lib/guard-service.jar
    cp src/main/resources/application.yml releases/config/
    tar czvf guard-service.tar.gz releases --transform s/^releases/guard-service/
}

package()
{
    package_module $1
}

release()
{
    return 0
}


print_help()
{
    echo "samples:"
    echo "----------------------------not rewriteable ---------------------------------------------"
    echo "build.sh make                :    make + package"
    echo "-----------------------------------------------------------------------------------------"
}

Main()
{
    echo $@
    if [ "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" -o $# -eq 0 ]; then
        print_help
    elif [ "$1" == "make" ];then
        make && package
    elif [ "$1" == "release" ];then
        make && package
    else
        $1
    fi
    return $?
}

Main $@

