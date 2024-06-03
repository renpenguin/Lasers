package main

import "core:fmt"
import SDL "vendor:sdl2"

ccw :: proc(a, b, c: Pos) -> bool {
	return (c.y - a.y) * (b.x - a.x) > (b.y - a.y) * (c.x - a.x)
}

lines_intersect :: proc(a, b, c, d: Pos) -> bool {
	return ccw(a, c, d) != ccw(b, c, d) && ccw(a, b, c) != ccw(a, b, d)
}

is_pos_on_screen :: proc(pos: Pos) -> bool {
	return(
		pos.x >= 0 &&
		pos.x < WINDOW_WIDTH &&
		pos.y >= 0 &&
		pos.y < WINDOW_HEIGHT \
	)
}

draw_laser :: proc(starting_pos, velocity: [2]f32, reflection_limit: int) {
	if reflection_limit < 1 {
		return
	}
	laser_pos := starting_pos

	drawing_laser: for {
		i_laser_pos := Pos{cast(i32)laser_pos.x, cast(i32)laser_pos.y}
		i_future_pos := Pos {
			cast(i32)(laser_pos.x + velocity.x),
			cast(i32)(laser_pos.y + velocity.y),
		}

		for wall in game.walls {
			if lines_intersect(
				i_laser_pos,
				i_future_pos,
				wall.pos1,
				wall.pos2,
			) {
				draw_laser(
					laser_pos,
					{velocity.x, -velocity.y}, // TODO calculate where the ray should be facing
					reflection_limit - 1,
				)
				break drawing_laser
			}

			if !is_pos_on_screen(i_laser_pos) {
				break drawing_laser
			}
		}

		laser_pos += velocity
	}

	SDL.RenderDrawLine(
		game.renderer,
		cast(i32)starting_pos.x,
		cast(i32)starting_pos.y,
		cast(i32)laser_pos.x,
		cast(i32)laser_pos.y,
	)
}
