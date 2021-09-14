#!/bin/bash
# i2ctransfer -f -y 4 w3@0x28 reg-MSB reg-LSB cnt-MSB cnt-LSB data crc
# i2ctransfer-write-96716K.sh "-f -y 4 w5@0x28" "reg-MSB reg-LSB data crc"
# i2ctransfer-write-96716K.sh 4 0x28 "reg-MSB reg-LSB" data

set -e

echo "i2ctransfer-write-96716K 20210914-1.0"

# 参数不能小于3
if [ $# -lt 4 ] 
then
	echo "Usage :param error!"
	echo "eg: $0 i2c-id i2c-address \"reg-MSB reg-LSB\" data"
	exit
fi

i2c_id=$1
i2c_address=$2
reg=$3
data=$4


# 计算cnt
# i2ctransfer -f -y 4 w2@0x28 0x00 0x00 r8
val=`i2ctransfer -f -y $i2c_id w2@$i2c_address 0x00 0x00 r4`
echo "i2ctransfer -f -y $i2c_id w2@$i2c_address 0x00 0x00 r4"
echo $val
# cnt=${val:0:9} # cnt-MSB cnt-LSB
# cnt + 1
cnt_MSB=${val:0:4}
cnt_LSB=${val:5:4}
cnt=$cnt_MSB${cnt_LSB:2:2}
((cnt=cnt+1))
hex16=$(printf '%04x' $cnt)
cnt="0x${hex16:0:2} 0x${hex16:2:2}"

# 计算crc
# P(x) = x8 + x6 + x3 + x2 + 1
ccitt=0x4d
# i2c_address_8bit = i2c_address < 1
i2c_address_8bit=$(printf '0x%02x' $((i2c_address<<1)))
crc=`crc8 $ccitt $i2c_address_8bit $reg $cnt $data`

# reg-MSB reg-LSB cnt-MSB cnt-LSB data crc
# i2ctransfer -f -y 4 w6@0x28 reg-MSB reg-LSB cnt-MSB cnt-LSB data crc
echo "i2ctransfer -f -y $i2c_id w6@$i2c_address $reg $cnt $data $crc"
i2ctransfer -f -y $i2c_id w6@$i2c_address $reg $cnt $data $crc


