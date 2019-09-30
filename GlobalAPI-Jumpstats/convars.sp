/* 
	Global API - Jumpstats Module ~ ConVars

	Author: 	Chuckles, Sikari & Zach47
	Source:		""
	
*/

ConVar gCV_Jumpstats_Logging;

void CreateConVars()
{
	gCV_Jumpstats_Logging = CreateConVar("globalapi_jumpstats_logging", "1", "Enables error logging of jumpstats (0 = Disabled, 1 = GET Requests only, 2 = Everything) [BEWARE: 2 can make a very big file!]", _, true, 0.0, true, 2.0);
	
	gCV_Jumpstats_Logging.AddChangeHook(OnJumpstatsLogging_Changed);
}

void OnJumpstatsLogging_Changed(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (!StrEqual(oldValue, newValue))
	{
		if (convar == gCV_Jumpstats_Logging)
		{
			gI_Logging = StringToInt(newValue);
		}
	}
}



