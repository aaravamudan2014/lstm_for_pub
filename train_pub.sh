#!/bin/bash

nsplits=1
nseeds=1
firstseed=300
huc="01"


gpucount=-1
for (( seed = $firstseed ; seed < $((nseeds+$firstseed)) ; seed++ )); do

  python3 main.py --n_splits=$nsplits --seed=$seed create_splits --experiment='E1' --huc=$huc
  wait

  for ((split = 0 ; split < $nsplits ; split++ )); do  

    gpucount=$(($gpucount + 1))
    gpu=$(($gpucount % 3))
    echo $seed $gpucount $gpu

    if [ "$1" = "lstm" ]
    then
      outfile="reports/pub_lstm_extended_nldas.$seed.$split.out"
      python3 main.py --gpu=$gpu --experiment='E1' --no_static=False --huc=$huc --concat_static=True --split=$split --split_file="data/kfold_splits_seed$seed.p" train 
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

python3 main.py --n_splits=$nsplits --seed=$seed evaluate --experiment='E1' --huc=$huc --split_file="data/kfold_splits_seed$seed.p"

