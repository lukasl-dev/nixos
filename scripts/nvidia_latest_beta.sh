curl -s https://www.nvidia.com/en-us/drivers/unix/ | perl -0777 -ne 'print "$1\n" if /Latest Beta Version.*?(\d+\.\d+\.\d+)/s'
