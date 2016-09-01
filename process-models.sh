#!/usr/bin/env bash
#clear

rm -Rf output

#process

for file_path in models/*.???
do

  file=${file_path##*/}
  output_dir=${file%.*}
  echo processing: $file
  lods=( "2" "3" "1") #percentage
  operators="import render convert "
  for lod in "${lods[@]}"
  do
    operators+=" lod convert render"
  done
  docker run --rm -v /Users/tiago/Nuxeo/projects/blender-scripts/scripts:/scripts:ro \
   -v /Users/tiago/Nuxeo/projects/blender-scripts/:/in:ro \
   -v /Users/tiago/Nuxeo/projects/blender-scripts/output:/out tcardoso/blender \
   -P /scripts/pipeline.py -- \
   --input /in/$file_path --outdir /out/$output_dir --operators $operators --lods ${lods[*]// / } --width 960 --height 600 --coords 0,0 90,0 0,90 90,90

  docker run --rm -v /Users/tiago/Nuxeo/projects/blender-scripts/output:/in \
  -v /Users/tiago/Nuxeo/projects/blender-scripts/output:/out tcardoso/collada2gltf -f /in/$output_dir/conversion-100.dae -o /out/$output_dir/conversion-100.gltf -e

  for lod in "${lods[@]}"
  do
    docker run --rm -v /Users/tiago/Nuxeo/projects/blender-scripts/output:/in \
    -v /Users/tiago/Nuxeo/projects/blender-scripts/output:/out tcardoso/collada2gltf -f /in/$output_dir/conversion-$lod.dae -o /out/$output_dir/conversion-$lod.gltf -e
  done

done
