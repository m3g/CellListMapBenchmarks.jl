julia_dir=/home/lovelace/proj/proj864/lmartine/.local/bin
namd_dir=/home/lovelace/proj/proj864/lmartine/NAMD_2.12_Linux-x86_64-multicore

basedir=/home/lovelace/proj/proj864/lmartine/2021_FortranCon/celllistmap_vs_namd

times="times100k.dat"

#echo `pwd` > $times

#for np in 32 28 24 20 16 14 12 10 8 4 2 1 ; do
for np in 2 1 ; do

    echo "Number of threads: $np" >> $times
	
    SECONDS=0
    $namd_dir/namd2 +p$np ./ne100k.namd > namd.log
    grep CPUTime: namd.log >> $times
    #echo "NAMD: $SECONDS seconds" >> $times
    echo "with np = $np"
    sleep 5

    SECONDS=0
    JULIA_EXCLUSIVE=1 $julia_dir/julia --project -t$np ./run100k.jl > celllistmap.log
    grep seconds celllistmap.log >> $times
    #echo "CellListMap: $SECONDS seconds" >> $times
    echo "with np = $np"
    sleep 5

done

