extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const GRAVITY = 9.8

var joystick_active = false
var joystick_value = Vector2.ZERO

# Starting inventory - player begins with tools and materials
var inventory = {
    "wood": 50,
    "stone": 30,
    "clay": 20,
    "thatch": 40,
    "axe": 1,
    "pickaxe": 1,
    "shovel": 1
}

func _ready():
    print("Player spawned with full inventory!")

func _physics_process(delta):
    # Apply gravity
    if not is_on_floor():
        velocity.y -= GRAVITY * delta

    # Movement from virtual joystick
    var direction = Vector3.ZERO
    if joystick_active and joystick_value.length() > 0.1:
        # Get camera directions
        var camera = $Camera3D if has_node("Camera3D") else null
        if camera:
            var cam_forward = -camera.global_transform.basis.z
            var cam_right = camera.global_transform.basis.x
            cam_forward.y = 0
            cam_right.y = 0
            cam_forward = cam_forward.normalized()
            cam_right = cam_right.normalized()
            direction = (cam_forward * -joystick_value.y + cam_right * joystick_value.x).normalized()

    if direction:
        velocity.x = direction.x * SPEED
        velocity.z = direction.z * SPEED
        # Rotate player to face movement direction
        rotation.y = atan2(-direction.x, -direction.z)
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)
        velocity.z = move_toward(velocity.z, 0, SPEED)

    move_and_slide()

func set_joystick(value: Vector2):
    joystick_value = value
    joystick_active = value.length() > 0.1

func add_item(item: String, amount: int):
    if inventory.has(item):
        inventory[item] += amount
    else:
        inventory[item] = amount
    print("✅ Picked up: ", amount, "x ", item)

func remove_item(item: String, amount: int) -> bool:
    if inventory.has(item) and inventory[item] >= amount:
        inventory[item] -= amount
        return true
    return false

func has_item(item: String, amount: int) -> bool:
    return inventory.has(item) and inventory[item] >= amount
