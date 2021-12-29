set subj='YANGYAN'
cd /Users/guofanhua/Desktop/gfh/work/Looming2020_EXP/stimulus/ZJY/data/$subj

optseq2 \
 --ntp 160 --tr 2 \
 --psdwin 2 10 \
 --tnullmin 6 \
 --tnullmax 10 \
 --ev LUpHit 2 4 \
 --ev LUpMiss 2 4 \
 --ev LDownHit 2 4 \
 --ev LDownMiss 2 4 \
 --ev RUpHit 2 4 \
 --ev RUpMiss 2 4 \
 --ev RDownHit 2 4 \
 --ev RDownMiss 2 4 \
 --o par \
 --mtx mat \
 --tsearch 0.1 \
 --nkeep 8



