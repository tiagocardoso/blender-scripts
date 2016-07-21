for file_path in models/*.???
do
  file=${file_path##*/}
  output_dir=output/${file%.*}
  # do something on $file
  echo processing: $file

  blender -b -F PNG -P scripts/render.py -- $file_path $output_dir/render 960 540

  echo render to png: $output_dir/render.png

  blender -b -P scripts/convert.py -- $file_path $output_dir/conversion.dae
  collada2gltf -f $output_dir/conversion.dae -b $output_dir/conversion.gltf
  rm $output_dir/conversion.dae

  echo converted to glTF: $output_dir/conversion.gltf

done
