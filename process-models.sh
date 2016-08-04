#!/usr/bin/env bash
#clear

rm -Rf output

#process

for file_path in models/*.???
do
  file=${file_path##*/}
  output_dir=output/${file%.*}
  echo processing: $file

  lods=( "2" "3" "1") #percentage
  operators="import render convert "
  for lod in "${lods[@]}"
  do
    operators+=" lod convert render"
  done
  blender -b -P scripts/pipeline.py -- --input $file_path --outdir $output_dir --operators $operators --lods ${lods[*]// / } --width 960 --height 600 --coords 0,0 90,0 0,90 90,90

  collada2gltf -f $output_dir/conversion-100.dae -o $output_dir/conversion-100.gltf -e
  for lod in "${lods[@]}"
  do
    collada2gltf -f $output_dir/conversion-$lod.dae -o $output_dir/conversion-$lod.gltf -e
  done

done
