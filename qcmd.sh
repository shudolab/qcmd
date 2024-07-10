#!/bin/bash

if [ $# -eq 0 ]; then
    # echo "Usage: [Q=QueueName] [P=NProcs] [T=NThreads] [C=NCpus] [G=NGpus] [M=Memory (GB)] [W=WallTime (hour)] [J=JobName] [O=LogDir] bash $0 [-I|command]"
    echo "Usage: [Q=QueueName] [ [P=NProcs] [C=NCpus] [M=Memory (GB)] | [G=NGpus] ] [W=WallTime (hour)] [J=JobName] [O=LogDir] bash $0 [-I|command]"
    exit 1
fi


# Set default values
if [ -z "$G" ]; then
    R="p=${P:=1}:t=${C:=1}:c=${C}:m=${M:=4}G"
else
    R="g=${G:=0}"
fi

if [ -z "$W" ]; then
    W=1
fi
if [ -z "$J" ]; then
    J="qcmd"
fi
if [ -n "$Q" ]; then
    partition="-p $Q"
fi
if [ -z "$O" ]; then
    O="."
fi

# Run
if [ "$*" = "-I" ]; then
    tssrun $partition --rsc "$R" -t "${W}:00" -pty /bin/bash
else
    export QCMD_CMD=$*
    sbatch ${partition} -t "${W}:00:00" --rsc "$R" -J "$J" -o "${O}/%x.o%j.out" << EOM
#!/bin/bash
set -x
hostname
date
srun bash -c "$QCMD_CMD"
date
EOM
fi
