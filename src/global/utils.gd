static func get_tile_id_by_collision(collision):
    if collision.collider.get_class() == "TileMap":
        var tilemap = collision.collider
        var tile_coordinates = get_tile_coordinates_by_collision(collision)
        var tile_index = tilemap.get_cellv(tile_coordinates)
        return tile_index
    else:
        printerr("Collider is not a TileMap!")
        return null

static func destroy_tile_by_collision(collision):
    var tilemap = collision.collider
    var tile_coordinates = get_tile_coordinates_by_collision(collision)
    tilemap.set_cellv(tile_coordinates, -1)

static func get_tile_coordinates_by_collision(collision):
    var tilemap = collision.collider
    if tilemap.get_class() == "TileMap":
        var collision_local_position = collision.position - tilemap.get_global_position()
        var tile_coordinates = tilemap.world_to_map(collision_local_position)
        return tile_coordinates
    else:
        printerr("Collider is not a TileMap!")
        return null
