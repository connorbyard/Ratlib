-- Ratlib cheat sheet.
-- NOTE: Grep with "rg category" or "rg category_procedure"

-- MATHS
rat.maths_clamp(value, minimum_value, maximum_value)                                                                    --> Clamp value to range
rat.maths_lerp(start_value, end_value, interpolation_amount)                                                            --> Linear interpolation
rat.maths_inverse_lerp(start_value, end_value, value)                                                                   --> Return interpolation amount
rat.maths_remap(value, input_minimum, input_maximum, output_minimum, output_maximum)                                    --> Remap value between ranges
rat.maths_round(value)                                                                                                  --> Round to nearest integer
rat.maths_sign(value)                                                                                                   --> Return -1, 0, or 1
rat.maths_distance(point_a_x, point_a_y, point_b_x, point_b_y)                                                          --> Distance between two points
rat.maths_snap(value, step_size)                                                                                        --> Snap value to nearest step
rat.maths_approach(current_value, target_value, step_size)                                                              --> Move value toward target
-- GEOMETRY
rat.geo_point_in_rect(point_x, point_y, rect_x, rect_y, rect_width, rect_height)                                        --> Point is inside rectangle
rat.geo_rects_overlap(rect_a_x, rect_a_y, rect_a_width, rect_a_height, rect_b_x, rect_b_y, rect_b_width, rect_b_height) --> Rectangles overlap
-- RESOLUTION
rat.res_initialise(width, height)                                                                                       --> Initialise virtual resolution
rat.res_update()                                                                                                        --> Update resolution scaling and mouse position
rat.res_push()                                                                                                          --> Begin virtual-resolution drawing
rat.res_pop()                                                                                                           --> End virtual-resolution drawing
-- SHAPES
rat.shape_line(start_x, start_y, end_x, end_y, color)                                                                   --> Draw line
rat.shape_rect(x, y, width, height, color)                                                                              --> Draw rectangle outline
rat.shape_rect_fill(x, y, width, height, color)                                                                         --> Draw filled rectangle
rat.shape_circle(center_x, center_y, radius, color)                                                                     --> Draw circle outline
rat.shape_circle_fill(center_x, center_y, radius, color)                                                                --> Draw filled circle
rat.shape_triangle(point_a_x, point_a_y, point_b_x, point_b_y, point_c_x, point_c_y, color)                             --> Draw triangle outline
rat.shape_triangle_fill(point_a_x, point_a_y, point_b_x, point_b_y, point_c_x, point_c_y, color)                        --> Draw filled triangle
rat.shape_polygon(points, color)                                                                                        --> Draw polygon outline
rat.shape_polygon_fill(points, color)                                                                                   --> Draw filled polygon
-- TWEENS
rat.tween_new(duration_seconds)                                                                                         --> Create tween
rat.tween_update(tween_state, delta_time)                                                                               --> Update tween
rat.tween_reset(tween_state)                                                                                            --> Reset tween
rat.tween_time(tween_state)                                                                                             --> Get tween time from 0 to 1
rat.tween_linear(time)                                                                                                  --> Linear easing
rat.tween_sine_in(time)                                                                                                 --> Sine ease in
rat.tween_sine_out(time)                                                                                                --> Sine ease out
rat.tween_sine_in_out(time)                                                                                             --> Sine ease in and out
rat.tween_hop(maximum_height, time)                                                                                     --> Hop up and down
rat.tween_bump(maximum_distance, time)                                                                                  --> Move out and back
rat.tween_pulse(minimum_value, maximum_value, time)                                                                     --> Pulse between two values
-- SPRITES
rat.sprite_load_atlas(path, sprite_width, sprite_height)                                                                --> Load sprite atlas
rat.sprite_draw(atlas, index, grid_x, grid_y)                                                                           --> Draw sprite from atlas
rat.sprite_animate_frames(atlas, first_index, last_index, fps, grid_x, grid_y)                                          --> Animate sprite frame range
