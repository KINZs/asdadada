/*
	Global API ~ Natives

	Author: 	Chuckles, Sikari & Zach47
	Source:		""

*/

void CreateNatives()
{
	CreateNative("GlobalAPI_SendRecord", Native_SendRecord);
	CreateNative("GlobalAPI_BanPlayer", Native_BanPlayer);
	CreateNative("GlobalAPI_GetAPIKey", Native_GetAPIKey);
	CreateNative("GlobalAPI_GetTickrate", Native_GetTickrate);
	CreateNative("GlobalAPI_GetMapID", Native_GetMapID);
	CreateNative("GlobalAPI_GetMapName", Native_GetMapName);
	CreateNative("GlobalAPI_GetMapPath", Native_GetMapPath);
	CreateNative("GlobalAPI_GetMapTier", Native_GetMapTier);
	CreateNative("GlobalAPI_GetMapFilesize", Native_GetMapFilesize);
	CreateNative("GlobalAPI_GetMapGlobalStatus", Native_GetMapGlobalStatus);
	CreateNative("GlobalAPI_GetAuthStatus", Native_GetAuthStatus);
	CreateNative("GlobalAPI_GetModeInfo", Native_GetModeInfo);
	CreateNative("GlobalAPI_GetRecordTop", Native_GetRecordTop);
	CreateNative("GlobalAPI_GetRecordTopEx", Native_GetRecordTopEx);
	CreateNative("GlobalAPI_GetRecordCount", Native_APIRecordList_Count);
	CreateNative("GlobalAPI_GetRecordByPlace", Native_APIRecordList_GetByIndex);

	CreateNative("APIRecordList.Count", Native_APIRecordList_Count);
	CreateNative("APIRecordList.GetByIndex", Native_APIRecordList_GetByIndex);
	CreateNative("APIRecord.ID", Native_APIRecord_ID);
	CreateNative("APIRecord.Teleports", Native_APIRecord_Teleports);
	CreateNative("APIRecord.Time", Native_APIRecord_Time);
	CreateNative("APIRecord.SteamID", Native_APIRecord_SteamID);
	CreateNative("APIRecord.PlayerName", Native_APIRecord_PlayerName);
	CreateNative("APIRecord.MapName", Native_APIRecord_MapName);
	CreateNative("APIRecord.Mode", Native_APIRecord_Mode);
	CreateNative("APIRecord.Stage", Native_APIRecord_Stage);
}
/*
{
    "id": 148336,
    "steamid64": 76561198003275950,
    "steam_id": "STEAM_1:1:21505111",
    "player_name": "$ikari",
    "server_id": 336,
    "map_id": 262,
    "stage": 0,
    "mode": "kz_timer",
    "tickrate": 128,
    "time": 18.258,
    "teleports": 0,
    "created_on": "2017-09-08T17:35:26",
    "updated_on": "2017-09-08T17:35:26",
    "updated_by": 0
  },
  */

public int Native_APIRecordList_Count(Handle plugin, int numParams)
{
	Handle hJson = GetNativeCell(1);

	if (hJson == INVALID_HANDLE)
	{
		return -1;
	}

	return json_array_size(hJson);
}

public int Native_APIRecordList_GetByIndex(Handle plugin, int numParams)
{
	Handle hJson = GetNativeCell(1);
	Handle hValue;
	char buffer[4096];
	
	if (hJson == INVALID_HANDLE)
	{
		return -1;
	}

	else if (json_is_array(hJson))
	{
		hValue = json_array_get(hJson, GetNativeCell(2));
		json_dump(hValue, buffer, sizeof(buffer));
	}
	delete hValue;
	
	SetNativeString(3, buffer, GetNativeCell(4));
	return 1;
}

public int Native_APIRecord_ID(Handle plugin, int numParams)
{
	Handle hJson = GetNativeCell(1);

	return json_object_get_int(hJson, "id");
}

public int Native_APIRecord_Teleports(Handle plugin, int numParams)
{
	Handle hJson = GetNativeCell(1);

	return json_object_get_int(hJson, "teleports");
}

public int Native_APIRecord_Time(Handle plugin, int numParams)
{
	Handle hJson = GetNativeCell(1);

	return view_as<int>(json_object_get_float(hJson, "time"));
}

public int Native_APIRecord_SteamID(Handle plugin, int numParams)
{
	Handle hJson = GetNativeCell(1);
	char buffer[256];

	json_object_get_string(hJson, "steam_id", buffer, sizeof(buffer));
	SetNativeString(2, buffer, GetNativeCell(3));
}

public int Native_APIRecord_PlayerName(Handle plugin, int numParams)
{
	Handle hJson = GetNativeCell(1);
	char buffer[256];

	json_object_get_string(hJson, "player_name", buffer, sizeof(buffer));
	SetNativeString(2, buffer, GetNativeCell(3));
}

public int Native_APIRecord_MapName(Handle plugin, int numParams)
{
	Handle hJson = GetNativeCell(1);
	char buffer[256];

	json_object_get_string(hJson, "map_name", buffer, sizeof(buffer));
	SetNativeString(2, buffer, GetNativeCell(3));
}

public int Native_APIRecord_Mode(Handle plugin, int numParams)
{
	Handle hJson = GetNativeCell(1);
	char buffer[256];

	json_object_get_string(hJson, "mode", buffer, sizeof(buffer));
	SetNativeString(2, buffer, GetNativeCell(3));
}

public int Native_APIRecord_Stage(Handle plugin, int numParams)
{
	Handle hJson = GetNativeCell(1);

	return json_object_get_int(hJson, "stage");
}

public int Native_SendRecord(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	GlobalMode mode = GetNativeCell(2);
	int stage = GetNativeCell(3);
	int teleportsUsed = GetNativeCell(4);
	float time = GetNativeCell(5);
	PostRecordCallback func = GetNativeCell(6);
	any data = GetNativeCell(7);
	
	return view_as<int>(PostRecord(plugin, func, client, mode, stage, teleportsUsed, time, data));
}

public Native_BanPlayer(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	PostBanCallback func = GetNativeCell(5);
	any data = GetNativeCell(6);

	char steamid[32], ban_type[32];
	char notes[512], stats[512];

	GetNativeString(2, ban_type, sizeof(ban_type));
	GetNativeString(3, notes, sizeof(notes));
	GetNativeString(4, stats, sizeof(stats));

	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	
	PostAPIBanPlayer(plugin, func, client, ban_type, notes, stats, data);
}

public int Native_GetRecordTop(Handle plugin, int numParams)
{
	char map[64];
	GetNativeString(1, map, sizeof(map));
	int stage = GetNativeCell(2);
	GlobalMode mode = GetNativeCell(3);
	bool noTeleports = view_as<bool>(GetNativeCell(4));
	int tickrate = GetNativeCell(5);
	int topCount = GetNativeCell(6);
	GetRecordTopCallback func = GetNativeCell(7);
	any data = GetNativeCell(8);
	
	return view_as<int>(GetRecordTop(plugin, func, map, stage, mode, noTeleports, tickrate, topCount, data));
}

public int Native_GetRecordTopEx(Handle plugin, int numParams)
{
	char map[64];
	GetNativeString(1, map, sizeof(map));
	int stage = GetNativeCell(2);
	GlobalMode mode = GetNativeCell(3);
	bool noTeleports = view_as<bool>(GetNativeCell(4));
	int tickrate = GetNativeCell(5);
	int topCount = GetNativeCell(6);
	GetRecordTopCallback func = GetNativeCell(7);
	any data = GetNativeCell(8);

	return view_as<int>(GetRecordTopEx(plugin, func, map, stage, mode, noTeleports, tickrate, topCount, data));
}

public int Native_GetAPIKey(Handle plugin, int numParams)
{
	SetNativeString(1, gSZ_API_Key, GetNativeCell(2));
}

public int Native_GetTickrate(Handle plugin, int numParams)
{
	return gI_tickRate;
}

public int Native_GetMapID(Handle plugin, int numParams)
{
	return gI_mapId;
}

public int Native_GetMapName(Handle plugin, int numParams)
{
	SetNativeString(1, gSZ_mapName, GetNativeCell(2));
}

public int Native_GetMapPath(Handle plugin, int numParams)
{
	SetNativeString(1, gSZ_mapPath, GetNativeCell(2));
}

public int Native_GetMapTier(Handle plugin, int numParams)
{
	return gI_mapTier;
}

public int Native_GetMapFilesize(Handle plugin, int numParams)
{
	return gI_mapfileSize;
}

public int Native_GetMapGlobalStatus(Handle plugin, int numParams)
{
	return gB_mapGlobalStatus;
}

public int Native_GetAuthStatus(Handle plugin, int numParams)
{
	GetAuthStatusCallback func = GetNativeCell(1);
	
	GetAuthStatus(gSZ_API_Key, plugin, func);
}

public int Native_GetModeInfo(Handle plugin, int numParams)
{
	GlobalMode mode = GetNativeCell(1);
	GetModeInfoCallback func = GetNativeCell(2);
	any data = GetNativeCell(3);
	
	GetModeInfo(plugin, func, mode, data);
}