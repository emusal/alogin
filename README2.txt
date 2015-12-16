This is the README file for ALOGIN (Automatic Login) tool

ALOGIN is a tool for automatic login to one or more hosts without entering 
password. ALOGIN use the login information for each registered host. And then, 
ALOGIN supports automatic login to a host directly or via multiple hosts that
is pre-configured as gateways.

Report bugs and issues at emusal@gmail.com

License: GPLv2

You can get the sources to the latest development version from the git 
repository:

git clone git://github.com/emusal/alogin.git


Basic Usage:
============
$ t emusal@svr1
  or
$ r emusal@svr2

Commands:
=========
t          xxx

           Options:  

           [-p]   putting a file to remote host
           [-g]   getting a file from remote host
           [-c]   executing a command
           [-L]   making tunnel port
           [-R]   making tunnel port

           Example 1: xxx

r          xxx

Other Useful Commands:
=====================
tver       xxx

           Usage:
           $ tver

ip         xxx

           usage:
           $ ip {hostname}

IP         xxx

           usage:
           $ ip {hostname}

getpwd     xxx

           usage:
           $ getpwd [user@]{hostname}

GETPWD     xxx

           usage:
           $ GETPWD [user@]{hostname}

dishost    xxx
disdupsvr  xxx
