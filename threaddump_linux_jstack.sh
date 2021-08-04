#!/bin/sh
# Takes the JavaApp PID as an argument.
# Make sure you set JAVA_HOME
# Create thread dumps a specified number of times (i.e. LOOP) and INTERVAL.
# Thread dumps will be collected in the file "jstack_threaddump.out" and "high-cpu.out"
# in the same directory from where this script is been executed.
# Collect them and send it for analysis
# Usage: sh ./threaddump_linux_jstack.sh <JAVA_APP_PID>
#
# Run this script Only when you notice a slow response / stuck behavior for the specified java process ($PID)
# Number of times to collect data.
LOOP=10
# Interval in seconds between data points.
INTERVAL=10

# Setting the Java Home, by giving the path where your JDK is kept
# USERS MUST SET THE JAVA_HOME before running this script following:

JAVA_HOME=/home/jdk1.7.0_21

for ((i=1; i <= $LOOP; i++))
do
   $JAVA_HOME/bin/jstack -l $1 >> jstack_threaddump.out
   _now=$(date)
   echo "${_now}" >> high-cpu.out
   top -b -n 1 -H -p $1 >> high-cpu.out
   echo "thread dump #" $i
   if [ $i -lt $LOOP ]; then
    echo "sleeping..."
    sleep $INTERVAL
  fi
done
