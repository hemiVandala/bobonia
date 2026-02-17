extends Node3D

const CHUNK_SIZE = 64
const TERRAIN_HEIGHT = 40.0
const WATER_LEVEL = 2.0

var chunks = {}
var noise: FastNoiseLite

func _ready():
    # Initialize procedural noise
    noise = FastNoiseLite.new()
    noise.seed = randi()
    noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
    noise.frequency = 0.005
    noise.fractal_octaves = 5
    
    print("🌍 Generating Bobonia world...")
    generate_initial_world()
    print("✅ World generated! Explore forests, mountains, rivers, and more!")

func generate_initial_world():
    # Generate a 7x7 grid of chunks around spawn
    for x in range(-3, 4):
        for z in range(-3, 4):
            generate_chunk(x, z)

func generate_chunk(cx: int, cz: int):
    var key = Vector2i(cx, cz)
    if chunks.has(key):
        return

    var mesh_instance = MeshInstance3D.new()
    var surface_tool = SurfaceTool.new()
    surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

    # Generate vertex grid
    var verts = []
    var step = 2  # Lower = higher detail, but slower

    for x in range(0, CHUNK_SIZE + 1, step):
        var row = []
        for z in range(0, CHUNK_SIZE + 1, step):
            var wx = cx * CHUNK_SIZE + x
            var wz = cz * CHUNK_SIZE + z
            var height = get_height(wx, wz)
            row.append(Vector3(x, height, z))
        verts.append(row)

    # Build triangles
    var cols = verts.size()
    var rows = verts[0].size()
    
    for x in range(cols - 1):
        for z in range(rows - 1):
            var v0 = verts[x][z]
            var v1 = verts[x+1][z]
            var v2 = verts[x][z+1]
            var v3 = verts[x+1][z+1]
            
            var color = get_biome_color(v0.y)
            
            # First triangle
            surface_tool.set_color(color)
            surface_tool.add_vertex(v0)
            surface_tool.set_color(color)
            surface_tool.add_vertex(v1)
            surface_tool.set_color(color)
            surface_tool.add_vertex(v2)
            
            # Second triangle
            surface_tool.set_color(color)
            surface_tool.add_vertex(v1)
            surface_tool.set_color(color)
            surface_tool.add_vertex(v3)
            surface_tool.set_color(color)
            surface_tool.add_vertex(v2)

    surface_tool.generate_normals()
    mesh_instance.mesh = surface_tool.commit()

    # Material
    var mat = StandardMaterial3D.new()
    mat.vertex_color_use_as_albedo = true
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
    mesh_instance.material_override = mat

    mesh_instance.position = Vector3(cx * CHUNK_SIZE, 0, cz * CHUNK_SIZE)
    add_child(mesh_instance)
    chunks[key] = mesh_instance

func get_height(x: float, z: float) -> float:
    # Layer multiple noise frequencies for realistic terrain
    var base = noise.get_noise_2d(x, z)
    var mountain = noise.get_noise_2d(x * 0.3, z * 0.3) * 2.0
    var detail = noise.get_noise_2d(x * 3.0, z * 3.0) * 0.2
    
    var h = (base + mountain * 0.4 + detail) * TERRAIN_HEIGHT
    return max(h, WATER_LEVEL - 0.5)

func get_biome_color(height: float) -> Color:
    # Realistic biome colors based on elevation
    if height < WATER_LEVEL:
        return Color(0.2, 0.4, 0.8)         # Water - blue
    elif height < 4.0:
        return Color(0.85, 0.75, 0.5)       # Beach/sand - tan
    elif height < 12.0:
        return Color(0.3, 0.6, 0.2)         # Grassland - green
    elif height < 22.0:
        return Color(0.25, 0.5, 0.15)       # Forest - dark green
    elif height < 30.0:
        return Color(0.5, 0.45, 0.4)        # Rocky mountain - gray brown
    else:
        return Color(0.95, 0.95, 1.0)       # Snow cap - white
