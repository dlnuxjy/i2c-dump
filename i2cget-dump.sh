#!/bin/bash
#	     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
#	00: 00 a0 00 00 00 00 00 ff 00 00 00 ff 00 00 00 6d
#	10: 00 00 00 00 00 00 00 00 83 01 00 00 00 00 00 00
#	20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#	30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#	40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#	50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#	60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#	70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#	80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#	90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#	a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#	b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#	c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#	d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#	e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#	f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

# i2cget -f -y 0 0x5b 0x06

# 因为i2cdump总是报错 i2cdump: block read failed，但是i2cget正常，所以使用i2cget来实现i2cdump格式的输出
# 读取错误，显示XX

echo "i2cget-dump 20210910-1.0"

# 参数不能小于2
if [ $# -lt 2 ] 
then
	echo "Usage :param error!"
	echo "$0 i2c-id i2c-address"
	exit
fi

i2c_id=$1
i2c_address=$2

echo "     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f"
#每次循环获取16个数据
i=0
j=0
cur=0
max=16
while ((j < $max))
do
	lines_str="$(printf '%.2x' $((i*j))):"
	i=0
	while ((i < $max))
	do
		#echo $i
		((cur = i + j*max))
		#echo $cur
		val=`i2cget -f -y $i2c_id $i2c_address 0x$(printf '%.2x' $cur) 2>/dev/null`
		#获取返回值
		#echo "return:$?"
		if [ "$?" != 0 ]
		then
			val=0xXX
		fi
		#echo $val
		#替换0x字样
		val=`echo $val | sed "s/0x//g"`
		lines_str+=" $val"
		#echo $val
		((i++))
	done
	echo $lines_str
	((j++))
done


