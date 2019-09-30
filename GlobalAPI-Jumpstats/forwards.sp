/* 
	Global API - Jumpstats Module ~ Forwards

	Author: 	Chuckles, Sikari & Zach47
	Source:		""
	
*/

public void API_OnAPIKeyReloaded()
{
	GlobalAPI_GetAPIKey(gSZ_API_Key, sizeof(gSZ_API_Key));
}

public void API_OnDevelopmentMode(bool developmentmode)
{
	gB_Staging = developmentmode;
}

public int KZTimer_OnJumpstatStarted(int client)
{
	in_air_calcs(client, true);
	g_jump[client][recording_jump] = true;
}

public int KZTimer_OnJumpstatInvalid(int client)
{
	Jumpstats_Reset(client);
}


