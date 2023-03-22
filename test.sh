# /bin/bash
mkdir -p result

for fcmm in `ls $1`/*.cmm;
do
    echo ${fcmm}
    ./src/parser $1/${fcmm} > result/${fcmm/%cmm/out} 
done