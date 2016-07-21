#clear

rm -Rf output

#process

for file_path in models/*.???
do
  file=${file_path##*/}
  output_dir=output/${file%.*}
  echo processing: $file

  blender -b -F PNG -P scripts/render.py -- $file_path $output_dir/render 960 540
  echo render to png: $output_dir/render.png

  blender -b -P scripts/convert.py -- $file_path $output_dir/conversion.gltf
  #collada2gltf -f $output_dir/conversion.dae -e -o $output_dir/conversion.gltf
  #rm $output_dir/conversion.dae

  lods=( 50 25 15 7 3)
  for lod in "${lods[@]}"
  do
    echo "rendering LOD of $lod"
    blender -b -P scripts/lod.py -- $file_path $output_dir/conversion-${lod}.dae $lod
    blender -b -F PNG -P scripts/render.py -- $output_dir/conversion-${lod}.dae $output_dir/render-${lod} 960 540
    #collada2gltf -f $output_dir/conversion-${lod}.dae -o $output_dir/conversion-${lod}.gltf -e
  done
done
