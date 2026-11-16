import bpy
import math
import os

# =============================================================================
# STUDIO RENDER SCRIPT (BLENDER CYCLES) - ASUS PROART PA602 GPU MOUNT
# =============================================================================
# Rendu photo-réaliste studio haute résolution des pièces et de l'assemblage.
# Utilisation : blender -b -P scripts/render_blender.py
# =============================================================================

def setup_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.render.engine = 'CYCLES'
    scene.cycles.device = 'CPU'
    scene.cycles.samples = 64
    scene.cycles.use_denoising = True
    scene.render.resolution_x = 1920
    scene.render.resolution_y = 1080

    # Environnement studio sombre
    world = bpy.data.worlds.new("StudioWorld")
    scene.world = world
    world.use_nodes = True
    bg = world.node_tree.nodes.get("Background")
    bg.inputs["Color"].default_value = (0.010, 0.010, 0.014, 1.0)
    bg.inputs["Strength"].default_value = 0.35

    # Sol studio avec doux reflet
    bpy.ops.mesh.primitive_plane_add(size=15.0, location=(0, 0, 0))
    floor = bpy.context.active_object
    floor.name = "StudioFloor"
    mat_floor = bpy.data.materials.new(name="FloorMat")
    mat_floor.use_nodes = True
    bsdf_f = mat_floor.node_tree.nodes.get("Principled BSDF")
    bsdf_f.inputs["Base Color"].default_value = (0.012, 0.012, 0.018, 1.0)
    bsdf_f.inputs["Roughness"].default_value = 0.32
    bsdf_f.inputs["Metallic"].default_value = 0.25
    floor.data.materials.append(mat_floor)

    # Éclairage studio 3-points + top
    # Key Light (lumière principale douce)
    key = bpy.data.lights.new(name="KeyLight", type='AREA')
    key.energy = 45.0
    key.size = 0.70
    key.color = (1.0, 0.96, 0.92)
    key_obj = bpy.data.objects.new(name="KeyLight", object_data=key)
    bpy.context.collection.objects.link(key_obj)
    key_obj.location = (-0.45, -0.70, 0.55)
    key_obj.rotation_euler = (math.radians(52), 0, math.radians(-32))

    # Fill Light (lumière de débouchage bleutée)
    fill = bpy.data.lights.new(name="FillLight", type='AREA')
    fill.energy = 18.0
    fill.size = 0.90
    fill.color = (0.88, 0.93, 1.0)
    fill_obj = bpy.data.objects.new(name="FillLight", object_data=fill)
    bpy.context.collection.objects.link(fill_obj)
    fill_obj.location = (0.60, -0.55, 0.35)
    fill_obj.rotation_euler = (math.radians(50), 0, math.radians(45))

    # Rim Light (contre-jour pour découper les arêtes)
    rim = bpy.data.lights.new(name="RimLight", type='AREA')
    rim.energy = 38.0
    rim.size = 0.50
    rim.color = (1.0, 0.90, 0.75)
    rim_obj = bpy.data.objects.new(name="RimLight", object_data=rim)
    bpy.context.collection.objects.link(rim_obj)
    rim_obj.location = (0.15, 0.55, 0.50)
    rim_obj.rotation_euler = (math.radians(-48), 0, math.radians(165))

    # Top Light (zénithale diffuse)
    top = bpy.data.lights.new(name="TopLight", type='AREA')
    top.energy = 16.0
    top.size = 0.60
    top.color = (1.0, 1.0, 1.0)
    top_obj = bpy.data.objects.new(name="TopLight", object_data=top)
    bpy.context.collection.objects.link(top_obj)
    top_obj.location = (0, -0.05, 0.70)
    top_obj.rotation_euler = (math.radians(10), 0, 0)

    # Caméra
    cam_data = bpy.data.cameras.new(name="StudioCamera")
    cam_data.lens = 75
    cam_obj = bpy.data.objects.new(name="StudioCamera", object_data=cam_data)
    bpy.context.collection.objects.link(cam_obj)
    scene.camera = cam_obj

    return scene, cam_obj

def setup_camera_target(cam_obj, target_xyz):
    # Ciblage automatique au centre géométrique du modèle
    empty = bpy.data.objects.new("CamTarget", None)
    bpy.context.collection.objects.link(empty)
    empty.location = target_xyz
    c = cam_obj.constraints.new(type='TRACK_TO')
    c.target = empty
    c.track_axis = 'TRACK_NEGATIVE_Z'
    c.up_axis = 'UP_Y'
    return empty

def create_tech_material(name, base_rgb, roughness=0.45, metallic=0.05, ao_strength=0.15):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    links = mat.node_tree.links
    nodes.clear()

    out_node = nodes.new(type="ShaderNodeOutputMaterial")
    bsdf = nodes.new(type="ShaderNodeBsdfPrincipled")
    ao = nodes.new(type="ShaderNodeAmbientOcclusion")
    ramp = nodes.new(type="ShaderNodeValToRGB")

    ao.inputs["Distance"].default_value = 0.015
    ao.samples = 16

    # Teinte assombrie dans les creux
    crevice_rgb = (base_rgb[0] * 0.45, base_rgb[1] * 0.45, base_rgb[2] * 0.45, 1.0)
    surface_rgb = (base_rgb[0], base_rgb[1], base_rgb[2], 1.0)

    ramp.color_ramp.elements[0].position = 0.15
    ramp.color_ramp.elements[0].color = crevice_rgb
    ramp.color_ramp.elements[1].position = 0.85
    ramp.color_ramp.elements[1].color = surface_rgb

    links.new(ao.outputs["Color"], ramp.inputs["Fac"])
    links.new(ramp.outputs["Color"], bsdf.inputs["Base Color"])
    links.new(bsdf.outputs["BSDF"], out_node.inputs["Surface"])

    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic
    return mat

def import_stl(stl_path, name):
    bpy.ops.wm.stl_import(filepath=stl_path)
    obj = bpy.context.selected_objects[0]
    obj.name = name
    obj.scale = (0.001, 0.001, 0.001)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return obj

def render_assembly(output_path, root_dir):
    scene, cam = setup_scene()
    stl_dir = os.path.join(root_dir, "stl_output")

    # Matériaux ProArt : Noir obsidienne satiné pour la platine PSU, Titane mat pour le riser, Noir profond pour les pieds
    mat_bracket = create_tech_material("MatBracket", (0.040, 0.042, 0.048), roughness=0.40, metallic=0.10)
    mat_tray    = create_tech_material("MatTray",    (0.065, 0.068, 0.075), roughness=0.36, metallic=0.12)
    mat_foot    = create_tech_material("MatFoot",    (0.020, 0.020, 0.024), roughness=0.55, metallic=0.02)

    # 1. Platine PSU (psu_bracket)
    # L'export est orienté avec rotate([90,0,0]) : on applique -90° pour la replacer en CAD natif
    bracket = import_stl(os.path.join(stl_dir, "psu_bracket.stl"), "PSU_Bracket")
    bracket.rotation_euler = (math.radians(-90), 0, 0)
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
    bracket.data.materials.append(mat_bracket)

    # 2. Plateau Riser (riser_tray)
    # Dans l'assemblage : Y = +60mm (+0.060m), Z = +60mm (+0.060m)
    tray = import_stl(os.path.join(stl_dir, "riser_tray.stl"), "Riser_Tray")
    tray.location = (0, 0.060, 0.060)
    tray.data.materials.append(mat_tray)

    # 3. Pieds de soutien (support_foot x2)
    # Dans l'assemblage : X = ±73mm (±0.073m), Y = 73mm (+0.073m), Z = -84mm (-0.084m)
    foot_left = import_stl(os.path.join(stl_dir, "support_foot.stl"), "Support_Foot_L")
    foot_left.location = (-0.073, 0.073, -0.084)
    foot_left.data.materials.append(mat_foot)

    foot_right = import_stl(os.path.join(stl_dir, "support_foot.stl"), "Support_Foot_R")
    foot_right.location = (0.073, 0.073, -0.084)
    foot_right.data.materials.append(mat_foot)

    # Centrer l'ensemble et poser la base des pieds sur le sol Z=0
    # Les pieds reposent à Z = -0.084m, on remonte donc tout de +0.084m
    z_offset = 0.084
    y_offset = -0.065 # Centrage en Y
    for o in [bracket, tray, foot_left, foot_right]:
        o.location.z += z_offset
        o.location.y += y_offset
        # Lissage avec découpe des arêtes vives mécaniques (EdgeSplit à 35°)
        mod = o.modifiers.new(name="EdgeSplit", type='EDGE_SPLIT')
        mod.split_angle = math.radians(35)

    # Vue Héro : Angle trois-quarts avant plongeant avec ciblage parfait au centre de masse
    cam.location = (0.55, -0.72, 0.42)
    cam.data.lens = 68
    setup_camera_target(cam, (0.0, 0.0, 0.13))

    scene.render.filepath = output_path
    bpy.ops.render.render(write_still=True)
    print(f"[OK] Rendu Assemblage Hero généré : {output_path}")

def render_rear_view(output_path, root_dir):
    scene, cam = setup_scene()
    stl_dir = os.path.join(root_dir, "stl_output")

    mat_bracket = create_tech_material("MatBracket", (0.040, 0.042, 0.048), roughness=0.40, metallic=0.10)
    mat_tray    = create_tech_material("MatTray",    (0.065, 0.068, 0.075), roughness=0.36, metallic=0.12)
    mat_foot    = create_tech_material("MatFoot",    (0.020, 0.020, 0.024), roughness=0.55, metallic=0.02)

    bracket = import_stl(os.path.join(stl_dir, "psu_bracket.stl"), "PSU_Bracket")
    bracket.rotation_euler = (math.radians(-90), 0, 0)
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
    bracket.data.materials.append(mat_bracket)

    tray = import_stl(os.path.join(stl_dir, "riser_tray.stl"), "Riser_Tray")
    tray.location = (0, 0.060, 0.060)
    tray.data.materials.append(mat_tray)

    foot_left = import_stl(os.path.join(stl_dir, "support_foot.stl"), "Support_Foot_L")
    foot_left.location = (-0.073, 0.073, -0.084)
    foot_left.data.materials.append(mat_foot)

    foot_right = import_stl(os.path.join(stl_dir, "support_foot.stl"), "Support_Foot_R")
    foot_right.location = (0.073, 0.073, -0.084)
    foot_right.data.materials.append(mat_foot)

    z_offset = 0.084
    y_offset = -0.065
    for o in [bracket, tray, foot_left, foot_right]:
        o.location.z += z_offset
        o.location.y += y_offset
        mod = o.modifiers.new(name="EdgeSplit", type='EDGE_SPLIT')
        mod.split_angle = math.radians(35)

    # Vue Arrière : Cadrage avec ciblage au centre
    cam.location = (-0.56, 0.65, 0.42)
    cam.data.lens = 68
    setup_camera_target(cam, (0.0, 0.0, 0.13))

    scene.render.filepath = output_path
    bpy.ops.render.render(write_still=True)
    print(f"[OK] Rendu Assemblage Arrière généré : {output_path}")

def render_printable_parts(output_path, root_dir):
    scene, cam = setup_scene()
    stl_dir = os.path.join(root_dir, "stl_output")

    mat_bracket = create_tech_material("MatBracket", (0.040, 0.042, 0.048), roughness=0.40, metallic=0.10)
    mat_tray    = create_tech_material("MatTray",    (0.065, 0.068, 0.075), roughness=0.36, metallic=0.12)
    mat_foot    = create_tech_material("MatFoot",    (0.020, 0.020, 0.024), roughness=0.55, metallic=0.02)

    # 1. Platine PSU posée à plat (orientation d'impression native)
    bracket = import_stl(os.path.join(stl_dir, "psu_bracket.stl"), "PSU_Bracket_Flat")
    bracket.location = (-0.11, -0.02, 0)
    bracket.data.materials.append(mat_bracket)

    # 2. Plateau Riser posé à plat
    tray = import_stl(os.path.join(stl_dir, "riser_tray.stl"), "Riser_Tray_Flat")
    tray.location = (0.11, -0.02, 0)
    tray.data.materials.append(mat_tray)

    # 3. Pied de support posé sur son patin
    foot = import_stl(os.path.join(stl_dir, "support_foot.stl"), "Support_Foot_Flat")
    foot.location = (0.0, 0.11, 0)
    foot.data.materials.append(mat_foot)

    for o in [bracket, tray, foot]:
        mod = o.modifiers.new(name="EdgeSplit", type='EDGE_SPLIT')
        mod.split_angle = math.radians(35)

    # Vue de dessus 3/4 montrant les 3 pièces prêtes à imprimer
    cam.location = (0.0, -0.75, 0.58)
    cam.data.lens = 65
    setup_camera_target(cam, (0.0, 0.04, 0.04))

    scene.render.filepath = output_path
    bpy.ops.render.render(write_still=True)
    print(f"[OK] Rendu Pièces Prêtes à Imprimer généré : {output_path}")

if __name__ == "__main__":
    script_dir = os.path.dirname(os.path.abspath(__file__))
    root_dir = os.path.dirname(script_dir)
    preview_dir = os.path.join(root_dir, "previews")
    os.makedirs(preview_dir, exist_ok=True)

    hero_png  = os.path.join(preview_dir, "blender_assembly_hero.png")
    rear_png  = os.path.join(preview_dir, "blender_assembly_rear.png")
    parts_png = os.path.join(preview_dir, "blender_printed_parts.png")

    print("=== Démarrage des rendus studio Blender Cycles ===")
    render_assembly(hero_png, root_dir)
    render_rear_view(rear_png, root_dir)
    render_printable_parts(parts_png, root_dir)
    print("=== Tous les rendus Blender sont terminés ! ===")
