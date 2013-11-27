from fcntl import ioctl
import sys, fcntl, termios, time

slen=1024 # sleep len
tlen=0 # total len
next_sleep=slen

if len(sys.argv) is 1: sys.exit()
tty=sys.argv[1]

file = open(tty,'w')
while 1:
	line = sys.stdin.readline(10240)
	if not line: break
	rlen = len(line)
	for i in range(rlen):
		fcntl.ioctl(file, termios.TIOCSTI, line[i])
	tlen += rlen
#	if tlen > next_sleep:
#		next_sleep += slen
#		time.sleep(5000/1000000.0)
	time.sleep(5000/1000000.0)
file.close()
