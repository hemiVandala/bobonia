
extends DirectionalLight3D

var time_of_day: float = 8.0  # Start at 8 AM (morning)
var day_length: float = 600.0  # 10 minutes = 1 full day
var current_day: int = 1

func _process(delta):
    # Advance time
    time_of_day += (24.0 / day_length) * delta
    
    # Loop back to midnight after 24 hours
    if time_of_day >= 24.0:
        time_of_day = 0.0
        current_day += 1
        print("☀️ Day ", current_day, " begins!")

    update_sun()

func update_sun():
    # Calculate sun angle based on time
    # 0 = midnight, 6 = sunrise, 12 = noon, 18 = sunset, 24 = midnight
    var angle = (time_of_day / 24.0) * TAU - PI/2
    rotation_degrees.x = rad_to_deg(angle)

    # Adjust brightness based on time of day
    if time_of_day >= 6.0 and time_of_day <= 18.0:
        # Daytime (6 AM to 6 PM)
        var t = (time_of_day - 6.0) / 12.0  # 0 to 1 across the day
        light_energy = sin(t * PI) * 1.5 + 0.1
        
        # Golden hour colors (sunrise and sunset)
        if time_of_day < 8.0 or time_of_day > 16.0:
            light_color = Color(1.0, 0.7, 0.4)  # Warm orange
        else:
            light_color = Color(1.0, 0.95, 0.85)  # Bright white-yellow
    else:
        # Nighttime
        light_energy = 0.05  # Very dim moonlight
        light_color = Color(0.3, 0.4, 0.6)  # Blue moonlight

func get_time_string() -> String:
    var h = int(time_of_day)
    var m = int((time_of_day - h) * 60)
    var period = "AM" if h < 12 else "PM"
    var display_hour = h if h <= 12 else h - 12
    if display_hour == 0:
        display_hour = 12
    return "%02d:%02d %s" % [display_hour, m, period]

func is_daytime() -> bool:
    return time_of_day >= 6.0 and time_of_day <= 18.0

func is_golden_hour() -> bool:
    return (time_of_day >= 6.0 and time_of_day
