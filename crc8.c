#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>

unsigned char crc8(unsigned char data, unsigned char crc, unsigned char ccitt)
{
	unsigned char j;
	crc ^= (data);
	for (j = 0; j < 8; j++)
	{
		if (crc & 0x80)
		{
			crc <<= 1;
			crc ^= ccitt;
		}
		else
		{
			crc <<= 1;
		}
	}
	return crc;
}

//将十六进制的字符串转换成unsigned char
unsigned char htoi(char s[])
{
	int i;
	unsigned char n = 0;
	if (s[0] == '0' && (s[1] == 'x' || s[1] == 'X'))
	{
		i = 2;
	}
	else
	{
		i = 0;
	}
	for (; (s[i] >= '0' && s[i] <= '9') || (s[i] >= 'a' && s[i] <= 'z') || (s[i] >= 'A' && s[i] <= 'Z'); ++i)
	{
		if (tolower(s[i]) > '9')
		{
			n = 16 * n + (10 + tolower(s[i]) - 'a');
		}
		else
		{
			n = 16 * n + (tolower(s[i]) - '0');
		}
	}
	return n;
}

int main(int argc, char *argv[])
{
	unsigned char c = 0x00;
	unsigned char ccitt = 0x00;
	if (argc < 3)
	{
		printf("param err!\n");
		printf("Usage:*/ %s ccitt data0 ... dataN\n", argv[0]);
		printf("eg: %s 0x1d 0x00 0x01\n", argv[0]);
		return 0;
	}

	ccitt = htoi(argv[1]);

	unsigned char crc = 0x00;
	for (int i = 2; i < argc; ++i)
	{
		c = htoi(argv[i]);
		crc = crc8(c, crc, ccitt);
	}

	printf("0x%02x\n", crc);

	return 0;
}
