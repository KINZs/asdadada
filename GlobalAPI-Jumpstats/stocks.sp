/* 
	Global API - Jumpstats Module ~ Stocks

	Author: 	Chuckles, Sikari & Zach47
	Source:		""
	
*/

stock void increment_counter(int[] counter, int client, int size)
{
	if(counter[client] == (size - 1))
	{
		counter[client] = 0;
	}
	else
	{
		counter[client]++;
	}
}

stock int decrement_counter(int[] counter, int client, int size)
{
	int new_counter = counter[client];
	
	if(new_counter == 0)
	{
		new_counter = size - 1;
	}
	else
	{
		new_counter--;
	}
	return new_counter;
}

stock void GetGroundOrigin(int client, float pos[3])
{
	float fOrigin[3];
	float result[3];
	GetClientAbsOrigin(client, fOrigin);
	TraceClientGroundOrigin(client, result, 100.0);
	pos = fOrigin;
	pos[2] = result[2];
}

stock float GetEyeAngles(int client)
{
	float EyeAngles[3];
	GetClientEyeAngles(client, EyeAngles);
	return EyeAngles;
}

stock int TraceClientGroundOrigin(int client, float result[3], float offset)
{
	float temp[2][3];
	GetClientEyePosition(client, temp[0]);
	temp[1] = temp[0];
	temp[1][2] -= offset;
	float mins[] =  { -16.0, -16.0, 0.0 };
	float maxs[] =  { 16.0, 16.0, 60.0 };
	Handle trace = TR_TraceHullFilterEx(temp[0], temp[1], mins, maxs, MASK_SHOT, TraceEntityFilterPlayer);
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(result, trace);
		CloseHandle(trace);
		return 1;
	}
	CloseHandle(trace);
	return 0;
}

stock bool TraceEntityFilterPlayer(int entity, int contentsMask)
{
	return entity > GetMaxClients();
}

stock float GetSpeed(int client)
{
	float fVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
	float float_speed = SquareRoot(Pow(fVelocity[0], 2.0) + Pow(fVelocity[1], 2.0));
	return float_speed;
}

stock float GetVelocity(int client)
{
	float fVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
	float fSpeed = SquareRoot(Pow(fVelocity[0], 2.0) + Pow(fVelocity[1], 2.0) + Pow(fVelocity[2], 2.0));
	return view_as<float>(fSpeed);
}

stock float StringToFloat4(float myFloat)
{
    char number[1024];
    FormatEx(number, sizeof(number), "%.4f", myFloat);
    return StringToFloat(number);
}

stock void runcmd_history(int client)
{
	//Flop the index over for our rotating buffer if over 149
	increment_counter(g_lastIndex, client, 150);

	int write_to_index = g_lastIndex[client];
	g_last150_buttons[client][write_to_index] = GetClientButtons(client);
}