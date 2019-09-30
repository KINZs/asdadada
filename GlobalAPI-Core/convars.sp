/*
	Global API ~ ConVars

	Author: 	Chuckles, Sikari & Zach47
	Source:		""

*/

ConVar gCV_DevelopmentMode;
ConVar gCV_PlayerLogIp;
ConVar gCV_KickIfBanned;

void CreateConVars()
{
	gCV_DevelopmentMode = CreateConVar("GlobalAPI_DevelopmentMode", "0", "Enables development mode", _, true, 0.0, true, 1.0);
	gCV_PlayerLogIp = CreateConVar("GlobalAPI_LogPlayerIP", "1", "Whether to log player IP to API", _, true, 0.0, true, 1.0);
	gCV_KickIfBanned = CreateConVar("GlobalAPI_KickIfBanned", "1", "Whether to kick banned players", _, true, 0.0, true, 1.0);

	gCV_DevelopmentMode.AddChangeHook(OnDevelopmentMode_Changed);
	gCV_PlayerLogIp.AddChangeHook(OnPlayerLogIP_Changed);
	gCV_KickIfBanned.AddChangeHook(OnKickIfBanned_Changed);
}

void OnDevelopmentMode_Changed(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (!StrEqual(oldValue, newValue))
	{
		if (convar == gCV_DevelopmentMode)
		{
			gB_Staging = gCV_DevelopmentMode.BoolValue;
			Call_API_OnDevelopmentMode_Changed(gCV_DevelopmentMode.BoolValue);
		}
	}
}

void OnPlayerLogIP_Changed(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (!StrEqual(oldValue, newValue))
	{
		if (convar == gCV_PlayerLogIp)
		{
			gCV_PlayerLogIp.BoolValue = view_as<bool>(StringToInt(newValue));
		}
	}
}

void OnKickIfBanned_Changed(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (!StrEqual(oldValue, newValue))
	{
		if (convar == gCV_KickIfBanned)
		{
			gCV_KickIfBanned.BoolValue = view_as<bool>(StringToInt(newValue));
			Call_API_OnKickIfBanned_Changed(gCV_KickIfBanned.BoolValue);
		}
	}
}

