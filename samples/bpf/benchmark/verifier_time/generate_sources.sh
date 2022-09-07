#!/bin/bash

NUMLOOP=100
intervals=$1
incre=$2
echo $1
echo $2

if [ -e "./libbpf-bootstrap/examples/c" ]; then
        echo "libbpf-bootstrap exists, not cloning..."
else
        echo "Cloning libbpf-bootstrap"
        git clone --recursive https://github.com/libbpf/libbpf-bootstrap.git 
fi

cd ./libbpf-bootstrap/examples/c
mkdir insn_bench

echo "Generating samples..."
for (( i=0; i<intervals; i++))
do
    echo hello
    sed -i "5s/.*/#define NUMLOOP $NUMLOOP/" minimal.bpf.c
    make -j32
    mv ./minimal ./insn_bench/minimal$i
    NUMLOOP=$((NUMLOOP+incre))
done

sed -i "5s/.*/#define NUMLOOP 600000/" minimal.bpf.c
make -j32
mv ./minimal ./insn_bench/minimal600000

sed -i "5s/.*/#define NUMLOOP 1000000/" minimal.bpf.c
make -j32
mv ./minimal ./insn_bench/minimal1000000

sed -i "5s/.*/#define NUMLOOP 2000000/" minimal.bpf.c
make -j32
mv ./minimal ./insn_bench/minimal2000000
