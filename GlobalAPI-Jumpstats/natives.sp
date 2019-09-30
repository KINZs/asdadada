/* 
	Global API - Jumpstats Module ~ Natives

	Author: 	Chuckles, Sikari & Zach47
	Source:		""
	
*/

void CreateNatives()
{
	CreateNative("GlobalAPI_SendJumpstat", Native_SendJumpstat);
	CreateNative("GlobalAPI_GetJumpstatTop", Native_GetJumpstatTop);
	CreateNative("GlobalAPI_GetJumpstatTopEx", Native_GetJumpstatTopEx);

	CreateNative("APIJumpRecordList.Count", Native_APIJumpRecordList_Count);
	CreateNative("APIJumpRecordList.GetByIndex", Native_APIJumpRecordList_GetByIndex);
	CreateNative("APIJumpRecord.ID", Native_APIJumpRecord_ID);
	CreateNative("APIJumpRecord.ServerID", Native_APIJumpRecord_ServerID);
	CreateNative("APIJumpRecord.SteamID", Native_APIJumpRecord_SteamID);
	CreateNative("APIJumpRecord.SteamID64", Native_APIJumpRecord_SteamID64);
	CreateNative("APIJumpRecord.PlayerName", Native_APIJumpRecord_PlayerName);
	CreateNative("APIJumpRecord.JumpType", Native_APIJumpRecord_JumpType);
	CreateNative("APIJumpRecord.Tickrate", Native_APIJumpRecord_Tickrate);
	CreateNative("APIJumpRecord.Distance", Native_APIJumpRecord_Distance);
	CreateNative("APIJumpRecord.Strafes", Native_APIJumpRecord_Strafes);
	CreateNative("APIJumpRecord.CreatedOn", Native_APIJumpRecord_CreatedOn);
}

public int Native_APIJumpRecordList_Count(Handle plugin, int numParams)
{
	Handle hJson = GetNativeCell(1);

	if (hJson == INVALID_HANDLE)
	{
		return -1;
	}

	return json_array_size(hJson);
}

public int Native_APIJumpRecordList_GetByIndex(Handle plugin, int numParams)
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

public int Native_APIJumpRecord_ID(Handle plugin, int numParams)
{
	Handle hJson = GetNativeCell(1);

	return json_object_get_int(hJson, "id");
}

public int Native_APIJumpRecord_ServerID(Handle plugin, int numParams)
{
	Handle hJson = GetNativeCell(1);
	
	return json_object_get_int(hJson, "server_id");
}

public int Native_APIJumpRecord_SteamID(Handle plugin, int numParams)
{
	Handle hJson = GetNativeCell(1);
	char buffer[256];

	json_object_get_string(hJson, "steam_id", buffer, sizeof(buffer));
	SetNativeString(2, buffer, GetNativeCell(3));
}

// is actually useless since we cant handle 64 bit integers, but too scared to delete
public int Native_APIJumpRecord_SteamID64(Handle plugin, int numParams)
{
	Handle hJson = GetNativeCell(1);

	return json_object_get_int(hJson, "steamid64");
}

public int Native_APIJumpRecord_PlayerName(Handle plugin, int numParams)
{
	Handle hJson = GetNativeCell(1);
	char buffer[256];

	json_object_get_string(hJson, "player_name", buffer, sizeof(buffer));
	SetNativeString(2, buffer, GetNativeCell(3));
}

public int Native_APIJumpRecord_JumpType(Handle plugin, int numParams)
{
	Handle hJson = GetNativeCell(1);
	
	return json_object_get_int(hJson, "jump_type");
}

public int Native_APIJumpRecord_Tickrate(Handle plugin, int numParams)
{
	Handle hJson = GetNativeCell(1);
	
	return json_object_get_int(hJson, "tickrate");
}

public int Native_APIJumpRecord_Distance(Handle plugin, int numParams)
{
	Handle hJson = GetNativeCell(1);

	return view_as<int>(json_object_get_float(hJson, "distance"));
}

public int Native_APIJumpRecord_Strafes(Handle plugin, int numParams)
{
	Handle hJson = GetNativeCell(1);

	return json_object_get_int(hJson, "strafe_count");
}

public int Native_APIJumpRecord_CreatedOn(Handle plugin, int numParams)
{
	Handle hJson = GetNativeCell(1);
	char buffer[256];

	json_object_get_string(hJson, "created_on", buffer, sizeof(buffer));
	SetNativeString(2, buffer, GetNativeCell(3));
}

public Native_SendJumpstat(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    APIJumptype jumptype = GetNativeCell(2);
    int jumpcolor = GetNativeCell(3);
    float distance = GetNativeCell(4);
    bool is_pb = GetNativeCell(5);
    PostJumpstatCallback func = GetNativeCell(6);
    any data = GetNativeCell(7);
    
    end_jump(plugin, func, client, jumptype, jumpcolor, distance, is_pb, data);
}

public Native_GetJumpstatTop(Handle plugin, int numParams)
{
	APIJumptype jumptype = GetNativeCell(1);
	GetJumpstatTopCallback callback = GetNativeCell(2);
	any data = GetNativeCell(3);

	GetJumpstatTop(plugin, callback, jumptype, data);
}

public Native_GetJumpstatTopEx(Handle plugin, int numParams)
{
	APIJumptype jumptype = GetNativeCell(1);
	bool bind = GetNativeCell(2);
	GetJumpstatTopCallback callback = GetNativeCell(3);
	any data = GetNativeCell(4);

	GetJumpstatTopEx(plugin, callback, jumptype, bind, data);
}