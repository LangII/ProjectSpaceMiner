
extends Node

#############################
# GENERATIONAL CONTROL VARS #
#############################

# scripts/Gameplay.gd
onready var gameplay_seed = hash('Beastie Boys')
#onready var gameplay_seed = 2926405890
#onready var gameplay_mini_map_test = true
onready var gameplay_mini_map_test = false
onready var gameplay_ship_start_pos_x = 370
onready var gameplay_ship_start_pos_y = 780

# scripts/tiles/BaseTileMapLogic.gd
onready var basetilemaplogic_tile_map_width = 200
onready var basetilemaplogic_tile_map_height = 200
onready var basetilemaplogic_noise_octaves = 3						# 1   <= X <= 9 (edge distortion)
onready var basetilemaplogic_noise_period = 64.0						# 0.1 <= X <= 256.0 (noise size)
onready var basetilemaplogic_noise_persistence = 0.5					# 0.0 <= X <= 1.0
onready var basetilemaplogic_noise_lacunarity = 2.0					# 0.1 <= X <= 4.0
onready var basetilemaplogic_boarder_wall_tile_level = 1				# 1	  <= X <= 3
onready var basetilemaplogic_boarder_wall_noise_max_height = 10
onready var basetilemaplogic_boarder_wall_noise_octaves = 2			# 1   <= X <= 9 (edge distortion)
onready var basetilemaplogic_boarder_wall_noise_period = 40.0			# 0.1 <= X <= 256.0 (noise size)
onready var basetilemaplogic_boarder_wall_noise_persistence = 0.9		# 0.0 <= X <= 1.0
onready var basetilemaplogic_boarder_wall_noise_lacunarity = 3.5		# 0.1 <= X <= 4.0
onready var basetilemaplogic_safe_zone_start_height = 50
onready var basetilemaplogic_tile_01_health = 80
onready var basetilemaplogic_tile_02_health = 500
onready var basetilemaplogic_tile_03_health = 2000
onready var basetilemaplogic_noise_settings_tile_level_0_low = 0.00
onready var basetilemaplogic_noise_settings_tile_level_0_high = 0.20
onready var basetilemaplogic_noise_settings_tile_level_1_low = 0.20
onready var basetilemaplogic_noise_settings_tile_level_1_high = 0.30
onready var basetilemaplogic_noise_settings_tile_level_2_low = 0.30
onready var basetilemaplogic_noise_settings_tile_level_2_high = 0.40
onready var basetilemaplogic_noise_settings_tile_level_3_low = 0.40
onready var basetilemaplogic_noise_settings_tile_level_3_high = 1.10

# scripts/tiles/MineralTileMapLogic.gd
onready var mineraltilemaplogic_mineral_map_01_tile_levels = [1]  # [1], [2], [3], [1, 2], [1, 3], [2, 3], or [1, 2, 3]
onready var mineraltilemaplogic_mineral_map_01_vein_attempts = 250
onready var mineraltilemaplogic_mineral_map_01_drop_value_min = 1
onready var mineraltilemaplogic_mineral_map_01_drop_value_max = 3
onready var mineraltilemaplogic_mineral_map_01_vein_size_min = 4
onready var mineraltilemaplogic_mineral_map_01_vein_size_max = 12
onready var mineraltilemaplogic_mineral_map_02_tile_levels = [1]  # [1], [2], [3], [1, 2], [1, 3], [2, 3], or [1, 2, 3]
onready var mineraltilemaplogic_mineral_map_02_vein_attempts = 150
onready var mineraltilemaplogic_mineral_map_02_drop_value_min = 1
onready var mineraltilemaplogic_mineral_map_02_drop_value_max = 3
onready var mineraltilemaplogic_mineral_map_02_vein_size_min = 2
onready var mineraltilemaplogic_mineral_map_02_vein_size_max = 8
onready var mineraltilemaplogic_mineral_map_03_tile_levels = [2]  # [1], [2], [3], [1, 2], [1, 3], [2, 3], or [1, 2, 3]
onready var mineraltilemaplogic_mineral_map_03_vein_attempts = 150
onready var mineraltilemaplogic_mineral_map_03_drop_value_min = 1
onready var mineraltilemaplogic_mineral_map_03_drop_value_max = 3
onready var mineraltilemaplogic_mineral_map_03_vein_size_min = 2
onready var mineraltilemaplogic_mineral_map_03_vein_size_max = 8

# scripts/EnemyGenLogic.gd
onready var enemygenlogic_gen_map_enemy_01_spawn_attempts_per_botton_perc_100_min = 5
onready var enemygenlogic_gen_map_enemy_01_spawn_attempts_per_botton_perc_100_max = 10
onready var enemygenlogic_gen_map_enemy_01_spawn_attempts_per_botton_perc_050_min = 5
onready var enemygenlogic_gen_map_enemy_01_spawn_attempts_per_botton_perc_050_max = 10
onready var enemygenlogic_gen_map_enemy_01_spawn_attempts_per_botton_perc_025_min = 5
onready var enemygenlogic_gen_map_enemy_01_spawn_attempts_per_botton_perc_025_max = 10
onready var enemygenlogic_gen_map_enemy_01_near_coords_dist_min = 2  # dists by tile
onready var enemygenlogic_gen_map_enemy_01_near_coords_dist_max = 8
onready var enemygenlogic_gen_map_enemy_01_home_radius_min = 4
onready var enemygenlogic_gen_map_enemy_01_home_radius_max = 10
onready var enemygenlogic_gen_map_enemy_01_count_per_swarm_min = 2
onready var enemygenlogic_gen_map_enemy_01_count_per_swarm_max = 4
onready var enemygenlogic_gen_map_enemy_02_spawn_attempts_per_botton_perc_100_min = 2
onready var enemygenlogic_gen_map_enemy_02_spawn_attempts_per_botton_perc_100_max = 10
onready var enemygenlogic_gen_map_enemy_02_spawn_attempts_per_botton_perc_050_min = 2
onready var enemygenlogic_gen_map_enemy_02_spawn_attempts_per_botton_perc_050_max = 10
onready var enemygenlogic_gen_map_enemy_02_spawn_attempts_per_botton_perc_025_min = 2
onready var enemygenlogic_gen_map_enemy_02_spawn_attempts_per_botton_perc_025_max = 5
onready var enemygenlogic_gen_map_enemy_02_near_coords_dist_min = 4  # dists by tile
onready var enemygenlogic_gen_map_enemy_02_near_coords_dist_max = 8
onready var enemygenlogic_gen_map_enemy_02_segment_count_min = 4
onready var enemygenlogic_gen_map_enemy_02_segment_count_max = 20
onready var enemygenlogic_gen_map_enemy_03_spawn_attempts_per_botton_perc_100_min = 1
onready var enemygenlogic_gen_map_enemy_03_spawn_attempts_per_botton_perc_100_max = 3
onready var enemygenlogic_gen_map_enemy_03_spawn_attempts_per_botton_perc_050_min = 2
onready var enemygenlogic_gen_map_enemy_03_spawn_attempts_per_botton_perc_050_max = 6
onready var enemygenlogic_gen_map_enemy_03_spawn_attempts_per_botton_perc_025_min = 2
onready var enemygenlogic_gen_map_enemy_03_spawn_attempts_per_botton_perc_025_max = 10
onready var enemygenlogic_gen_map_enemy_03_near_coords_dist_min = 2  # dists by tile
onready var enemygenlogic_gen_map_enemy_03_near_coords_dist_max = 4
onready var enemygenlogic_gen_enemy01_type = 'off'  # 'auto', 'manual', or 'off'
onready var enemygenlogic_gen_enemy01_manual_x = 10
onready var enemygenlogic_gen_enemy01_manual_y = 20
onready var enemygenlogic_gen_enemy01_manual_per_swarm_count = 2
onready var enemygenlogic_gen_enemy01_manual_home_radius = 4
onready var enemygenlogic_gen_enemy02_type = 'off'  # 'auto', 'manual', or 'off'
onready var enemygenlogic_gen_enemy02_manual_x = 10
onready var enemygenlogic_gen_enemy02_manual_y = 30
onready var enemygenlogic_gen_enemy02_manual_segment_count = 12
onready var enemygenlogic_gen_enemy03_type = 'manual'  # 'auto', 'manual', or 'off'
onready var enemygenlogic_gen_enemy03_manual_x = 10
onready var enemygenlogic_gen_enemy03_manual_y = 40
onready var enemygenlogic_gen_enemy03_manual_dir = 130

##########################
# BEHAIORAL CONTROL VARS #
##########################

# scripts/Ship.gd
onready var ship_move_acc = 250
onready var ship_move_max_speed = 180
onready var ship_move_max_speed_resistance = 5
onready var ship_spin_acc = 2000
onready var ship_spin_max_speed = 7
onready var ship_spin_max_speed_resistance = 10
onready var ship_turret_cool_down_wait_time = 0.4
onready var ship_max_terrain_col_dmg = 2.0
onready var ship_max_health = 200
onready var ship_col_dmg_speed_modifier = 0.75
onready var ship_physical_armor = 0.02
onready var ship_drop_pick_up_radius = 100
onready var ship_enemy_area_col_strength_mod = 800
onready var ship_control_type = 'shuffle_board'  # 'classic_asteroids' or 'shuffle_board'

# scripts/Hud.gd
onready var hud_drop_display_count = 3
onready var hud_health_under_tween_duration = 1.0

# scripts/Bullet01.gd
onready var bullet01_speed = 450
onready var bullet01_dmg = 20
onready var bullet01_lifetime_wait_time = 10.0
onready var bullet01_col_particles_lifetime = 1.0
onready var bullet01_col_particle_displacement_mod = 10

# scripts/Missile01.gd
onready var missile01_speed = 50.0
onready var missile01_rot_speed = 0.025
onready var missile01_no_rot_target_deg = 30.0
onready var missile01_blast_map_blastarea2d01_dist = 50.0
onready var missile01_blast_map_blastarea2d01_dmg = 20.0
onready var missile01_blast_map_blastarea2d02_dist = 10.0
onready var missile01_blast_map_blastarea2d02_dmg = 100.0
onready var missile01_blast_particles_00_map_amount = 20
onready var missile01_blast_particles_00_map_explosiveness = 0.5
onready var missile01_blast_particles_00_map_initial_velocity = 100
onready var missile01_blast_particles_00_map_linear_accel = -100
onready var missile01_blast_particles_map_blastparticles2d01_amount = 80
onready var missile01_blast_particles_map_blastparticles2d01_initial_velocity = 100
onready var missile01_blast_particles_map_blastparticles2d01_linear_accel = -100
onready var missile01_blast_particles_map_blastparticles2d02_amount = 40
onready var missile01_blast_particles_map_blastparticles2d02_initial_velocity = 30
onready var missile01_blast_particles_map_blastparticles2d02_linear_accel = -40
onready var missile01_ship_col_impulse_mod = 20.0
onready var missile01_destroy_drop_chance = 0.2

# scripts/Enemy01.gd
onready var enemy01_rot_speed = 4.0
onready var enemy01_move_speed = 150.0
onready var enemy01_aggressive_dist_range = 400.0
onready var enemy01_pursue_chance_reduction = 0.25
onready var enemy01_can_dmg_ship_delay = 0.5
onready var enemy01_ship_col_impulse_mod = 80.0
onready var enemy01_max_health = 80.0
onready var enemy01_dmg = 10.0
onready var enemy01_dmg_to_self_mod = 0.5
onready var enemy01_lifeend_particles_lifetime = 1.0
onready var enemy01_drop_value_min = 1
onready var enemy01_drop_value_max = 3
onready var enemy01_wounded_map_high_min = 0.0
onready var enemy01_wounded_map_high_max = 0.25
onready var enemy01_wounded_map_high_speed = 0.25
onready var enemy01_wounded_map_low_min = 0.25
onready var enemy01_wounded_map_low_max = 0.5
onready var enemy01_wounded_map_low_speed = 1.0

# scripts/Enemy02.gd
onready var enemy02_gen_new_target_within_dist = 40
onready var enemy02_new_target_dist_min = 200
onready var enemy02_new_target_dist_max = 400
onready var enemy02_can_gen_new_target_from_col_delay = 2
onready var enemy02_col_new_target_angle_expansion = 15
onready var enemy02_segment_max_health = 80.0
onready var enemy02_wounded_map_high_min = 0.0
onready var enemy02_wounded_map_high_max = 0.25
onready var enemy02_wounded_map_high_speed = 0.25
onready var enemy02_wounded_map_low_min = 0.25
onready var enemy02_wounded_map_low_max = 0.5
onready var enemy02_wounded_map_low_speed = 1.0
onready var enemy02_min_dist_to_ship_to_target = 1_000.0
onready var enemy02_can_dmg_ship_delay = 0.5
onready var enemy02_dmg = 20.0
onready var enemy02_dmg_to_self_mod = 0.5
onready var enemy02_ship_col_impulse_mod = 20.0
onready var enemy02_tail_spin_speed = 5
onready var enemy02_speed_min = 100
onready var enemy02_speed_max = 60
onready var enemy02_speed_to_dist_modifier = 120.0  # windows=60.0 | mac=120.0
onready var enemy02_inner_turn_sharpness_min = 2.5
onready var enemy02_inner_turn_sharpness_max = 0.2  # windows=1.5 | mac=0.2

# scripts/Enemy03.gd
onready var enemy03_floating_linear_speed_min = 10.0
onready var enemy03_floating_linear_speed_max = 100.0
onready var enemy03_floating_rotate_speed_min = 0.01
onready var enemy03_floating_rotate_speed_max = 0.2
onready var enemy03_rolling_change_dir_chance_min = 0.001
onready var enemy03_rolling_change_dir_chance_max = 0.300
onready var enemy03_rolling_mov_mod = 0.04  # windows=0.08 | mac=0.04
onready var enemy03_rolling_rot_mod = 2.0  # windows=4.0 | mac=2.0
onready var enemy03_can_dmg_ship_delay = 1.0
onready var enemy03_col_with_ship_speed_mod = 0.80
onready var enemy03_ship_col_impulse_mod = 80.0
onready var enemy03_max_health = 80.0
onready var enemy03_dmg = 10.0
onready var enemy03_dmg_to_self_mod = 0.5
onready var enemy03_wounded_map_high_min = 0.0
onready var enemy03_wounded_map_high_max = 0.25
onready var enemy03_wounded_map_high_speed = 0.25
onready var enemy03_wounded_map_low_min = 0.25
onready var enemy03_wounded_map_low_max = 0.5
onready var enemy03_wounded_map_low_speed = 1.0
onready var enemy03_turret_rot_speed_min = 2
onready var enemy03_turret_rot_speed_max = 6
onready var enemy03_can_shoot_missile_delay = 2.0
onready var enemy03_turret_is_near_wall_min = 90
onready var enemy03_ship_detect_ray_dist = 300
onready var enemy03_drop_value_min = 1
onready var enemy03_drop_value_max = 5













