/* 
	Global API - Jumpstats Module

	Author: 	Chuckles, Sikari & Zach47
	Source:		""
	
*/

#include <GlobalAPI-Core>
#include <GlobalAPI-Jumpstats>

// ======================= VARIABLES ======================= //

// Jump Variables
int g_jump[MAXPLAYERS + 1][jump];
int g_last150_buttons[MAXPLAYERS + 1][150];
int g_lastIndex[MAXPLAYERS + 1];

// API Variables
int gI_Logging = 1;
int gI_tickRate = -1;
bool gB_Staging = false;
char gSZ_API_Key[128] = "";

// Log Variables
char gSZ_mainLog[256];
char gSZ_logPath[PLATFORM_MAX_PATH];

char gC_JumpTypePhrases[APIJumptype_Count][] =
{
	"None",
	"Longjump",
	"Bhop",
	"Multihop",
	"Weirdjump",
	"Drophop",
	"Countjump",
	"Ladderjump"
};

// ======================= DEFINITIONS ======================= //

#define UPDATER "http://updater.global-api.com/GlobalAPI-Jumpstats.txt"
#define SECURE "https://"

#define API_JUMPSTATS "kztimerglobal.com/api/v1/jumpstats"

// ======================= INCLUDES ======================= //

#include <sdktools>
#include <SteamWorks>

#include "GlobalAPI-Jumpstats/misc.sp"
#include "GlobalAPI-Jumpstats/json.sp"
#include "GlobalAPI-Jumpstats/stocks.sp"
#include "GlobalAPI-Jumpstats/natives.sp"
#include "GlobalAPI-Jumpstats/convars.sp"
#include "GlobalAPI-Jumpstats/forwards.sp"

#include "GlobalAPI-Jumpstats/apicalls/postjumpstat.sp"
#include "GlobalAPI-Jumpstats/apicalls/getjumpstattop.sp"

#undef REQUIRE_PLUGIN
#include <updater>

// ======================= FORMATTING ====================== //

#pragma semicolon 1
#pragma newdecls required
#pragma dynamic 131072

// ======================= PLUGIN INFO ====================== //

public Plugin myinfo =
{
	name = "GlobalAPI-Jumpstats",
	author = "Sikari",
	description = "Jumpstats module for GlobalAPI",
	version = GlobalAPI_Jumpstats_Version,
	url = "https://bitbucket.org/kztimerglobalteam/globalrecordssmplugin"
};

// ======================= MAIN CODE ======================= //

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary("GlobalAPI-Jumpstats");
	
	CreateNatives();

	return APLRes_Success;
}

public void OnPluginStart()
{
	if (GetEngineVersion() != Engine_CSGO)
	{
		SetFailState("Sorry, this plugin is only for CS:GO");
	}

	if (LibraryExists("updater"))
	{
		Updater_AddPlugin(UPDATER);
	}

	CreateConVars();
	CreateLogFile();

	AutoExecConfig(true, "GlobalAPI-Jumpstats");
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "updater"))
	{
		Updater_AddPlugin(UPDATER);
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "updater"))
	{
		Updater_RemovePlugin();
	}
}

public void OnMapStart()
{
	ResetVars();
	GetVariables();
}

public void OnClientDisconnect(int client)
{
	Jumpstats_Reset(client);
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if (IsPlayerAlive(client) && IsValidClient(client))
	{
		if (g_jump[client][recording_jump])
		{
			in_air_calcs(client, false);
		}

		runcmd_history(client);
	}

	return Plugin_Continue;
}