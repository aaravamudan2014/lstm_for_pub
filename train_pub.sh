#!/bin/bash

nsplits=1
nseeds=1
firstseed=300

gpucount=-1
huc="$2"
exp="$3"
run_dir="run_${exp}_${huc}"


for (( seed = $firstseed ; seed < $((nseeds+$firstseed)) ; seed++ )); do

  python3 main.py --n_splits=$nsplits --seed=$seed --huc=$huc --experiment=$exp create_splits 
  wait

  for ((split = 0 ; split < $nsplits ; split++ )); do  

    gpucount=$(($gpucount + 1))
    gpu=$(($gpucount % 3))
    echo $seed $gpucount $gpu

    if [ "$1" = "lstm" ]
    then

      outfile="reports/pub_lstm_extended_nldas.$seed.$split.out"
      python3 main.py --gpu=$gpu --no_static=False --experiment=$exp --huc=$huc --concat_static=True --split=$split --split_file="data/kfold_splits_seed$seed.p" train 
      # > $outfile &

    else
      echo bad model choice
      exit
    fi

    if [ $gpu -eq 2 ]
    then
      wait
    fi

  done
done


python3 main.py --n_splits=$nsplits --seed=$firstseed --huc=$huc --experiment=$exp --run_dir="runs/${run_dir}" --split_file="data/kfold_splits_seed$firstseed.p" evaluate
wait
