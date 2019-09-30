/* 
	Global API - Core

	Author: 	Chuckles, Sikari & Zach47
	Source:		""
	
*/

// ======================= VARIABLES ======================= //

bool gB_Staging = false;
bool gB_Jumpstats_Module = false;

// Map Info Variables
int gI_mapId = -1;
int gI_mapTier = -1;
int gI_mapfileSize = -1;
bool gB_mapGlobalStatus = false;
char gSZ_mapName[128] = "";
char gSZ_mapPath[128] = "";

// Misc
Handle g_ThisPlugin = INVALID_HANDLE;
int gI_tickRate = -1;
char gSZ_API_Key[128] = "";

char gSZ_logPath[256];

char gC_GlobalModes[][] = 
{
	"kz_vanilla", 
	"kz_simple", 
	"kz_timer"
};

// ======================= DEFINITIONS ===================== //

#define UPDATER "http://updater.global-api.com/GlobalAPI-Core.txt"
#define SECURE "https://"

#define API_PLAYER "kztimerglobal.com/api/v1/players/steamid/"
#define API_RECORD "kztimerglobal.com/api/v1/records"
#define API_BAN "kztimerglobal.com/api/v1/bans/"
#define API_MAP "kztimerglobal.com/api/v1/maps"
#define API_STATUS "kztimerglobal.com/api/v1/auth/status"
#define API_MODES "kztimerglobal.com/api/v1/modes"

// ======================= INCLUDES ======================= //

#include <SteamWorks>
#include <smjansson>

#include <GlobalAPI-Core>
#include "GlobalAPI-Core/map.sp"
#include "GlobalAPI-Core/misc.sp"
#include "GlobalAPI-Core/server.sp"
#include "GlobalAPI-Core/convars.sp"
#include "GlobalAPI-Core/bans.sp"
#include "GlobalAPI-Core/player.sp"
#include "GlobalAPI-Core/records.sp"
#include "GlobalAPI-Core/natives.sp"
#include "GlobalAPI-Core/forwards.sp"

#undef REQUIRE_PLUGIN
#include <updater>

// ======================= FORMATTING ====================== //

#pragma semicolon 1
#pragma newdecls required
#pragma dynamic 131072

// ======================= PLUGIN INFO ====================== //

public Plugin myinfo =
{
	name = "GlobalAPI-Core",
	author = "Sikari",
	description = "",
	version = GlobalAPI_Version,
	url = "https://bitbucket.org/kztimerglobalteam/globalrecordssmplugin"
};

// ======================= MAIN CODE ======================= //

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNatives();
	CreateForwards();
	RegPluginLibrary("GlobalAPI-Core");
	
	g_ThisPlugin = myself;
	return APLRes_Success;
}

public void OnPluginStart()
{
	if (GetEngineVersion() != Engine_CSGO)
	{
		SetFailState("This plugin is only for CS:GO.");
	}

	if (LibraryExists("updater"))
	{
		Updater_AddPlugin(UPDATER);
	}

	CreateCommands();
	CreateConVars();
	CreateLogFile();

	AutoExecConfig(true, "GlobalAPI");
}

public void OnMapStart()
{
	gB_Staging = gCV_DevelopmentMode.BoolValue;

	ResetOldVariables();
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "updater"))
	{
		Updater_AddPlugin(UPDATER);
	}
	
	if (StrEqual(name, "GlobalAPI-Jumpstats"))
	{
		gB_Jumpstats_Module = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "updater"))
	{
		Updater_RemovePlugin();
	}
	
	if (StrEqual(name, "GlobalAPI-Jumpstats"))
	{
		gB_Jumpstats_Module = false;
	}
}

public void API_OnVariablesReset()
{
	LoadAPIKey();
	LoadTickrate();
	LoadMap();
}

public Action ReloadAPIKey(int client, int args)
{
	if (client != 0)
	{
		PrintToChat(client, "This command is meant to be used from server console");
		return Plugin_Handled;
	}
	LoadAPIKey();
	Call_API_OnAPIKeyReloaded();

	return Plugin_Handled;
}

public Action ShowInitMsg(int client, int args)
{
	if (client != 0)
	{
		PrintToChat(client, "This command is meant to be used from server console");
		return Plugin_Handled;
	}
	PrintInitMessage();

	return Plugin_Handled;
}

public void OnClientAuthorized(int client, const char[] auth)
{
	if (IsFakeClient(client) || !IsClientConnected(client))
	{
		return;
	}
	
	GetPlayerInfo(client, auth);
}