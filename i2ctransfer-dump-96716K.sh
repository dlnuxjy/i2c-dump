#!/bin/bash
#	     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
#	0000: 00 a0 00 00 00 00 00 ff 00 00 00 ff 00 00 00 6d
#	0010: 00 00 00 00 00 00 00 00 83 01 00 00 00 00 00 00
#	0020: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#	0030: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#	0040: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#	0050: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#	0060: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#	0070: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#	0080: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#	0090: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#	00a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#	00b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#	00c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#	00d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#	00e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#	00f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#	01f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#	...
#	fff0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

# i2ctransfer -f -y 4 w2@0x28 0x00 0x00 r8

# 使用i2ctransfer命令获取96716K芯片的所有寄存器信息
# 96716K 寄存器地址是16位
# i2c数据格式: 
# 1. 单字节读取: CNT-MSB CNT-LSB Data CRC
# 2. 多字节读取: CNT-MSB CNT-LSB Data CRC Data CRC ... Data CRC
# 这里选用多字节读取提高读取速度
# 读取错误，显示XX

echo "i2ctransfer-dump-96716K 20210913-1.0"

# 参数不能小于2
if [ $# -lt 2 ] 
then
	echo "Usage :param error!"
	echo "$0 i2c-id i2c-address"
	exit
fi

i2c_id=$1
i2c_address=$2

echo "       0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f"
#每次循环获取16个数据
i=0
j=0
cur=0
maxi=16
maxj=4096
while ((j < $maxj))
do
	lines_str="$(printf '%.4x' $((i*j))):"
	i=0
	while ((i < $maxi))
	do
		#echo $i
		((cur = i + j*maxi))
		#echo $cur
        hex16=$(printf '%.4x' $cur)
        s0=${hex16:0:2}
        s1=${hex16:2:2}
		# 每次读出的字节数2字节cnt,每个数据配有一个CRC,所以乘以2
		((readCnt=2+maxi*2))
        val=`i2ctransfer -f -y $i2c_id w2@$i2c_address 0x$s0 0x$s1 r$readCnt 2>/dev/null`
		#获取返回值
		#echo "return:$?"
		if [ "$?" != 0 ]
		then
			val="0xXX 0xXX 0xXX 0xXX 0xXX 0xXX 0xXX 0xXX 0xXX 0xXX 0xXX 0xXX 0xXX 0xXX 0xXX 0xXX 0xXX 0xXX"
		fi
		# 多字节读取: CNT-MSB CNT-LSB Data CRC Data CRC ... Data CRC
		val=${val:10} #去掉CNT
		k=0
		while ((k < $maxi))
		do
			#取data
			data=" ${val:0:4}"
			#替换0x字样
			lines_str+=" `echo $data | sed "s/0x//g"`"
			#val缩短10
			val=${val:10}
			((k++))
		done
		((i+=maxi))
	done
	echo $lines_str
	((j++))
done


