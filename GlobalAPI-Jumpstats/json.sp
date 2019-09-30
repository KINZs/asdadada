/* 
	Global API - Jumpstats Module ~ JSON

	Author: 	Chuckles, Sikari & Zach47
	Source: 	""
	
*/

public void update_json_tick_data(int client)
{
	float origin[3], abs_origin[3], ang[3], fVelocity[3];
	int buttons = GetClientButtons(client);
	int tick = g_jump[client][total_ticks];

	GetGroundOrigin(client, origin);
	GetClientAbsOrigin(client, abs_origin);
	GetClientEyeAngles(client, ang);
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
		
	int last_t = tick - 1;
		
	//msl_count
	if(tick > 1)
	{
		//Set this diff
		g_jump[client][eye_diff][tick] = ang[1] - g_jump[client][eye_ang][y][last_t];
			
		//Clamp for -180 -> 0 -> 180
		if(g_jump[client][eye_diff][tick] > 180)
		{
			g_jump[client][eye_diff][tick] -= 360;
		}
		else if(g_jump[client][eye_diff][tick] < -180)
		{
			g_jump[client][eye_diff][tick] += 360;
		}
			
		//MSL Check
		if(FloatAbs(g_jump[client][eye_diff][tick] - g_jump[client][eye_diff][last_t]) <= 0.005 && FloatAbs(g_jump[client][eye_diff][tick] - g_jump[client][eye_diff][last_t - 1]) <= 0.005 && FloatAbs(g_jump[client][eye_diff][tick - 1]) >= 1.00)
		{
			g_jump[client][msl_count] += 1;
				
		}
	}

	//Eye Angles
	g_jump[client][eye_ang][x][tick] = ang[0];
	g_jump[client][eye_ang][y][tick] = ang[1];
	g_jump[client][eye_ang][z][tick] = ang[2];

	//Player Position
	g_jump[client][player_pos][x][tick] = origin[0];
	g_jump[client][player_pos][y][tick] = origin[1];
	g_jump[client][player_pos][z][tick] = abs_origin[2];

	//Player Velocity
	g_jump[client][player_vel][x][tick] = fVelocity[0];
	g_jump[client][player_vel][y][tick] = fVelocity[1];
	g_jump[client][player_vel][z][tick] = fVelocity[2];

	//Buttons
	g_jump[client][player_buttons][tick] = buttons;
}

void in_air_calcs(int client, bool start = false) 
{
	if(start)
	{
		g_jump[client][recording_jump] = true;
	}

	int tick = g_jump[client][total_ticks];

	if (tick < 2000 && g_jump[client][recording_jump])
	{
		update_json_tick_data(client);
		bind_check(client);
		update_strafes(client);
		
		g_jump[client][total_ticks]++;
	}
}

char[] JumpToJSONString(int client)
{	
	char json_jump_string[32000];		
	Handle jump_json	=	json_object();
	Handle tick_array	=	json_array();
	
	Handle tick_object = json_object();
	Handle eye_a = json_array();
	Handle player_p = json_array();
	Handle player_v = json_array();

	//JSON
	for (int i = 0; i <= g_jump[client][total_ticks] - 1; i++)
	{
		tick_object = json_object();
		
		eye_a = json_array();
		player_p = json_array();
		player_v = json_array();
		
		//Reduce precision a bit
		float eye_x = g_jump[client][eye_ang][x][i];
		float eye_y = g_jump[client][eye_ang][y][i];
		float eye_z = g_jump[client][eye_ang][y][i];
		
		float player_p_x = g_jump[client][player_pos][x][i];
		float player_p_y = g_jump[client][player_pos][y][i];
		float player_p_z = g_jump[client][player_pos][z][i];
		
		float player_v_x = g_jump[client][player_vel][x][i];
		float player_v_y = g_jump[client][player_vel][y][i];
		float player_v_z = g_jump[client][player_vel][z][i];
		
		json_array_append_new(eye_a, json_real(eye_x));
		json_array_append_new(eye_a, json_real(eye_y));
		json_array_append_new(eye_a, json_real(eye_z));
		
		json_array_append_new(player_p, json_real(player_p_x));
		json_array_append_new(player_p, json_real(player_p_y));
		json_array_append_new(player_p, json_real(player_p_z));
		
		json_array_append_new(player_v, json_real(player_v_x));
		json_array_append_new(player_v, json_real(player_v_y));
		json_array_append_new(player_v, json_real(player_v_z));
		
		json_object_set_new(tick_object, "e" , eye_a);
		json_object_set_new(tick_object, "p" , player_p);
		json_object_set_new(tick_object, "v" , player_v);
		json_object_set_new(tick_object, "b", json_integer(g_jump[client][player_buttons][i]));
		
		json_array_append_new(tick_array, tick_object);
	}
	
	json_object_set_new(jump_json, "ticks", tick_array);
	json_dump(jump_json, json_jump_string, sizeof(json_jump_string), 0);

	return json_jump_string;
}