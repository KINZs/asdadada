/*
	Global API ~ Misc

	Author: 	Chuckles, Sikari & Zach47
	Source:		""

*/

void CreateCommands()
{
	RegAdminCmd("sm_reload_apikey", ReloadAPIKey, ADMFLAG_ROOT, "Reloads the Global API Key");
	RegAdminCmd("sm_print_initmsg", ShowInitMsg, ADMFLAG_ROOT, "Prints the GlobalAPI init message in server console");
}

void CreateLogFile()
{
	BuildPath(Path_SM, gSZ_logPath, sizeof(gSZ_logPath), "globalapi-log.txt");
	Handle logFile = OpenFile(gSZ_logPath, "a");
	CloseHandle(logFile);
}

void APILog(char[] url, char[] method, int statusCode, char[] content = "")
{
	if (StrEqual(content, ""))
	{
		LogToFileEx(gSZ_logPath, "[Global API] HTTP (%s) %d (%s)", method, statusCode, url);
	}
	else
	{
		LogToFileEx(gSZ_logPath, "[Global API] HTTP (%s) %d (%s) -> %s", method, statusCode, url, content);
	}
}

void LoadAPIKey()
{
	if (FileExists("cfg/sourcemod/globalrecords.cfg"))
	{
		Handle APIKey = OpenFile("cfg/sourcemod/globalrecords.cfg", "r");
		
		if (APIKey != INVALID_HANDLE)
		{
			char tempsplit[2][128];
			ReadFileLine(APIKey, gSZ_API_Key, sizeof(gSZ_API_Key));
			TrimString(gSZ_API_Key);

			if (ExplodeString(gSZ_API_Key, "records_api_key", tempsplit, sizeof(tempsplit), sizeof(tempsplit[])) > 1)
			{
				TrimString(tempsplit[1]);
				Format(gSZ_API_Key, sizeof(gSZ_API_Key), "%s", tempsplit[1]);
			}
		}

		else
		{
			LogError("[GLOBAL API] Cannot read API Key!");
		}
		CloseHandle(APIKey);
	}

	else
	{
		LogError("[GLOBAL API] Cannot open globalrecords.cfg for reading! Make sure it exists");
	}
}

public int LoadTickrate()
{
	int tickRate = RoundFloat(1.0 / GetTickInterval());
	
	gI_tickRate = tickRate;
}

public void ResetOldVariables()
{
	gI_tickRate = -1;
	gI_mapId = -1;
	gI_mapTier = -1;
	gI_mapfileSize = -1;
	gB_mapGlobalStatus = false;
	FormatEx(gSZ_API_Key, sizeof(gSZ_API_Key), "");

	API_OnVariablesReset();
}

public void PrintInitMessage()
{
	PrintToServer("");
	PrintToServer("========================= GlobalAPI %s =========================", GlobalAPI_Version);
	PrintToServer("======= The server has been init with the following settings ======");
	PrintToServer("===================================================================");
	PrintToServer("======= Development Mode: %s", gB_Staging ? "Staging" : "Production");
	PrintToServer("======= API Key: %s", gSZ_API_Key);
	PrintToServer("======= Tickrate: %d", gI_tickRate);
	PrintToServer("======= Kick If Banned: %s", FindConVar("GlobalAPI_KickIfBanned").BoolValue ? "Yes" : "No");
	PrintToServer("======= Jumpstats Module: %s", gB_Jumpstats_Module ? "Enabled" : "Not Enabled");
	PrintToServer("===================================================================");
	PrintToServer("======= Map Name: %s", gSZ_mapName);
	PrintToServer("======= Map Path: %s", gSZ_mapPath);
	PrintToServer("======= Map ID: %d", gI_mapId);
	PrintToServer("======= Map Tier: %d", gI_mapTier);
	PrintToServer("======= Map Filesize: %d", gI_mapfileSize);
	PrintToServer("======= Map Validation Status: %s", gB_mapGlobalStatus ? "Global" : "Not Global");
	PrintToServer("===================================================================");
	PrintToServer("======= Local Map Filesize: %d", FileSize(gSZ_mapPath));
	PrintToServer("======= Matches Global Filesize?: %s", gI_mapfileSize == FileSize(gSZ_mapPath) ? "OK" : "X");
	PrintToServer("===================================================================");
	PrintToServer("");
}
