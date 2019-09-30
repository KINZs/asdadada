/* 
	Global API - Jumpstats Module ~ Misc

	Author: 	Chuckles, Sikari & Zach47
	Source: 	""
	
*/

void CreateLogFile()
{
	BuildPath(Path_SM, gSZ_logPath, sizeof(gSZ_logPath), "globalapi-jumpstats-log.txt");
	BuildPath(Path_SM, gSZ_mainLog, sizeof(gSZ_mainLog), "globalapi-log.txt");
	Handle logFile = OpenFile(gSZ_logPath, "a");
	Handle mainLog = OpenFile(gSZ_mainLog, "a");
	CloseHandle(logFile);
	CloseHandle(mainLog);
}

void APILog(char[] url, char[] method, int statusCode, char[] content = "")
{
	if (StrEqual(content, ""))
	{
		LogToFileEx(gSZ_mainLog, "[Global API] HTTP (%s) %d (%s)", method, statusCode, url);
	}
	else
	{
		Handle logFile = OpenFile(gSZ_logPath, "a");
		char text[85000];
		FormatEx(text, sizeof(text), "[Global API Jumpstats] HTTP (%s) %d (%s) -> %s", method, statusCode, url, content);
		WriteFileString(logFile, text, true);
		CloseHandle(logFile);
	}
}

public void end_jump(Handle plugin, PostJumpstatCallback func, int client, APIJumptype jumptype, int jumpcolor, float distance, bool pb, any data)
{
	int tick = g_jump[client][total_ticks];

	//Set End Tick
	g_jump[client][end_tick] = g_jump[client][total_ticks];

	update_json_tick_data(client);

	float x1 = g_jump[client][player_pos][x][0];
	float x2 = g_jump[client][player_pos][x][tick];

	float y1 = g_jump[client][player_pos][y][0];
	float y2 = g_jump[client][player_pos][y][tick];
	float full_distance = SquareRoot(Pow((x2 - x1), 2.0) + Pow((y2 - y1), 2.0)) + 32;

	//Ladders are special....
	if(jumptype == APIJumptype_Ladderjump)
	{
		full_distance = distance;
	}

	bool worth_saving = false;

	//Godlike nobinds, Godlike PBs and Ownages go to API
	//With the exception of Ladderjumps and Countjumps
	//Which are ownages-only that are sent to API

	if (jumpcolor >= 3 && !g_jump[client][is_cj_boost] && jumptype != APIJumptype_Ladderjump && jumptype != APIJumptype_Countjump)
	{
		worth_saving = true;
	}

	else if(jumpcolor >= 3 && pb)
	{
		worth_saving = true;
	}

	else if(jumpcolor >= 4)
	{
		worth_saving = true;
	}

	if (worth_saving)
	{
		SendJumpToAPI(plugin, func, client, jumptype, full_distance, data);
	}

	else
	{
		// This needs some explaining
		// Because only the original plugin
		// can delete plugin handles,
		// we need to call the callback so
		// the original plugin can delete the handle
		// Otherwise this would end up in an access violation
		Call_StartFunction(plugin, func);
		Call_PushCell(true);
		Call_PushCell(0);
		Call_PushCell(0);
		Call_PushCell(data);
		Call_Finish();
		Jumpstats_Reset(client);
	}
}

void Jumpstats_Reset(int client) 
{	
	//Reset Jump Globals
	g_jump[client][start_tick] = 0;
	g_jump[client][end_tick] = 0;
	g_jump[client][total_ticks] = 0;
	
	//MSL
	g_jump[client][msl_count] = 0;
	g_jump[client][recording_jump] = false;	
	
	//Bind
	g_jump[client][ticks_holding_both_c_j] = 0;
	g_jump[client][still_holding_bind] = false;
	g_jump[client][is_cj_boost] = false;
	g_jump[client][is_cj_bind] = false;
	
	//Strafes
	g_jump[client][strafe_count] = 0;
}

void bind_check(int client)
{
	int tick = g_jump[client][total_ticks];
	int buttons = GetClientButtons(client);
	int read_index = decrement_counter(g_lastIndex, client, 150);
	
	bool only_duck = !(buttons & IN_JUMP) && (buttons & IN_DUCK);
	bool only_jump = (buttons & IN_JUMP) && !(buttons & IN_DUCK);
	bool both_jump_duck = (buttons & IN_JUMP) && (buttons & IN_DUCK);
	bool neither_jump_duck = !(buttons & IN_JUMP) && !(buttons & IN_DUCK);
	
	//First tick is different - it shouldn't be, rip...
	if(tick == 0)
	{
		if(both_jump_duck && !(g_last150_buttons[client][read_index] & IN_DUCK))
		{
			g_jump[client][still_holding_bind] = true;
			g_jump[client][ticks_holding_both_c_j]++;
			g_jump[client][is_cj_boost] = true;
		}
		else
		{
			g_jump[client][still_holding_bind] = false;
			g_jump[client][ticks_holding_both_c_j] = 0;
		}
	}
	else
	{
		if(g_jump[client][still_holding_bind])
		{
			if(both_jump_duck)
			{
				g_jump[client][ticks_holding_both_c_j]++;
			}
			else if(only_jump || only_duck)
			{
				g_jump[client][still_holding_bind] = false;
				g_jump[client][ticks_holding_both_c_j] = 0;
			}
			else if(neither_jump_duck)
			{
				g_jump[client][still_holding_bind] = false;
				if(g_jump[client][ticks_holding_both_c_j] > 2)
				{
					g_jump[client][is_cj_bind] = true;
				}
			}
		}
	}
}

void update_strafes(int client)
{
	int tick = g_jump[client][total_ticks];
	//Eye Diffs are already calculated in MSL!
	float old_eye_diff = 0.00; 
	float new_eye_diff = 0.00; 
	
	//If we can go back a tick, do it.  If not, diff is 0 :(
	if(tick > 0)
	{
		new_eye_diff = g_jump[client][eye_diff][tick]; 
	}
	if(tick > 1)
	{
		old_eye_diff = g_jump[client][eye_diff][tick - 1];
	}
	
	if(FloatAbs(new_eye_diff) > 0 && tick > 0)
	{
		if((new_eye_diff > 0 && old_eye_diff < 0) || (new_eye_diff < 0 && old_eye_diff > 0) || (old_eye_diff == 0))
		{
			g_jump[client][strafe_count]++;
		}
	}
}

bool SendJumpToAPI(Handle plugin, PostJumpstatCallback func, int client, APIJumptype jumptype, float distance, any data)
{
	int crouch_bind = g_jump[client][is_cj_bind];
	int crouch_boost = g_jump[client][is_cj_boost];
	int strafe_count_db = g_jump[client][strafe_count];

	//MSL for DB, floor of 4
	int msl_count_db = 0;

	if(g_jump[client][msl_count] > 3)
	{
		msl_count_db = g_jump[client][msl_count];
	}
	
	//Get Player Name
	char steamid[64], name[64];
	GetClientName(client, name, sizeof(name));
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));

	PostAPIJumpstat(plugin, func, client, steamid, jumptype, distance, msl_count_db, crouch_bind, 0, crouch_boost, strafe_count_db, data);
	Jumpstats_Reset(client);
}

void ResetVars()
{
	gI_tickRate = -1;
	FormatEx(gSZ_API_Key, sizeof(gSZ_API_Key), "");

	gB_Staging = FindConVar("GlobalAPI_DevelopmentMode").BoolValue;
}

void GetVariables()
{
	GlobalAPI API;

	API.GetAPIKey(gSZ_API_Key, sizeof(gSZ_API_Key));
	gI_tickRate = API.GetTickrate();
}