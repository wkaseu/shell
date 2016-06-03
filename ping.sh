for((i=10;i<1500;i++))
    do
        ping -s $i -c 1 $1
        echo "index:$i"
    done
