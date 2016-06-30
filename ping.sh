for((i=420;i<512;i++))
    do
        ping -s $i -c 1 $1
#        echo "index:$i"
    done
