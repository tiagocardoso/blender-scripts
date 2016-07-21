import bpy, json, os, sys
from copy import copy
from math import pi, cos, sin, degrees
from mathutils import Vector
from blendergltf import blendergltf

# Clean the scene
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete()

# get the arguments after --
render_args = sys.argv[sys.argv.index("--")+1:]

if len(render_args) != 2:
    sys.exit("Must provide <input file> <output file>")

(infile, outfile) = render_args

# process the input filename
dirpath, basename = os.path.split(infile)
basename, ext = os.path.splitext(basename)
ext = ext.lower()

print("Importing %s " % (ext))
if ext.startswith("."):
    ext = ext[1:]

if ext == 'stl':
    # import an stl model
    bpy.ops.import_mesh.stl(filepath=infile)

elif ext == 'obj':
    # import an obj model
    bpy.ops.import_scene.obj(
        filepath=infile,
        use_smooth_groups=False,
        use_image_search=False,
        axis_forward="Y",
        axis_up="Z")

elif ext == 'dae':
    print("Importing COLLADA")
    # import a collada model
    bpy.ops.wm.collada_import(filepath=infile)

# get the meshes
meshes = [obj for obj in bpy.data.objects if obj.type == 'MESH']

print("Found %d meshes" % len(meshes))

# process the input filename
out_dirpath, out_basename = os.path.split(outfile)
out_basename, out_ext = os.path.splitext(out_basename)
out_ext = out_ext.lower()

print("Exporting %s " % (out_ext))
if out_ext.startswith("."):
    out_ext = out_ext[1:]

if out_ext == 'stl':
    print("Exporting COLLADA")
    # export an stl model
    bpy.ops.export_mesh.stl(filepath=outfile)

elif out_ext == 'obj':
    print("Exporting COLLADA")
    # export an obj model
    bpy.ops.export_scene.obj(filepath=outfile, axis_forward='-Z', axis_up='Y')

elif out_ext == 'dae':
    print("EXporting COLLADA")
    # export a collada model
    bpy.ops.wm.collada_export(filepath=outfile)
elif out_ext == 'gltf':
    print("Exporting glTF")
    scene = {
        'actions': bpy.data.actions,
        'camera': bpy.data.cameras,
        'lamps': bpy.data.lamps,
        'images': bpy.data.images,
        'materials': bpy.data.materials,
        'meshes': bpy.data.meshes,
        'objects': bpy.data.objects,
        'scenes': bpy.data.scenes,
        'textures': bpy.data.textures,
    }
    # Copy properties to settings
    settings = blendergltf.default_settings.copy()
    #settings['materials_export_shader'] = BoolProperty(name='Export Shaders', default=False)
    #settings['images_embed_data'] = BoolProperty(name='Embed Image Data', default=False)

    gltf = blendergltf.export_gltf(scene, settings)
    with open(outfile, 'w') as fout:
        json.dump(gltf, fout, indent=4, sort_keys=True, check_circular=False)
