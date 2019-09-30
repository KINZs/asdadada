/*
	Global API ~ Player

	Author: 	Chuckles, Sikari & Zach47
	Source:		""

*/

public void GetPlayerInfo(int client, const char[] auth)
{
	char requestUrl[512];
	if (gB_Staging && gCV_PlayerLogIp.BoolValue)
	{
		char ipaddress[64];
		GetClientIP(client, ipaddress, sizeof(ipaddress));
		Format(requestUrl, sizeof(requestUrl), "%sstaging.%s%s/ip/%s", SECURE, API_PLAYER, auth, ipaddress);
	}

	else if (!gB_Staging && gCV_PlayerLogIp.BoolValue)
	{
		char ipaddress[64];
		GetClientIP(client, ipaddress, sizeof(ipaddress));
		Format(requestUrl, sizeof(requestUrl), "%s%s%s/ip/%s", SECURE, API_PLAYER, auth, ipaddress);
	}

	else if (gB_Staging && !gCV_PlayerLogIp.BoolValue)
	{
		Format(requestUrl, sizeof(requestUrl), "%sstaging.%s%s", SECURE, API_PLAYER, auth);
	}

	else
	{
		Format(requestUrl, sizeof(requestUrl), "%s%s%s", SECURE, API_PLAYER, auth);
	}

	if (GetFeatureStatus(FeatureType_Native, "SteamWorks_CreateHTTPRequest") == FeatureStatus_Available)
	{

		DataPack dp = CreateDataPack();
		dp.WriteCell(GetClientUserId(client));
		dp.WriteString(requestUrl);

		Handle playerInfo = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, requestUrl);
		
		if (playerInfo == INVALID_HANDLE) 
		{
			delete dp;
			LogError("Failed to GET player info because there was a problem creating the HTTP request.");
			return;
		}
		
		SteamWorks_SetHTTPRequestHeaderValue(playerInfo, "Accept", "application/json");
		SteamWorks_SetHTTPRequestHeaderValue(playerInfo, "X-ApiKey", gSZ_API_Key);
		SteamWorks_SetHTTPRequestContextValue(playerInfo, dp);
		SteamWorks_SetHTTPCallbacks(playerInfo, OnPlayerInfo);
		SteamWorks_SendHTTPRequest(playerInfo);
	}
}

public int OnPlayerInfo(Handle request, bool failure, bool requestSuccessful, EHTTPStatusCode statusCode, DataPack dp)
{
	int status = view_as<int>(statusCode);

	if (failure || !requestSuccessful || status == 404 || status == 500 || status == 503)
	{
		char requestUrl[512];

		dp.Reset();
		dp.ReadCell();
		dp.ReadString(requestUrl, sizeof(requestUrl));
		delete dp;

		APILog(requestUrl, "GET", status);
	}

	else
	{
		SteamWorks_GetHTTPResponseBodyCallback(request, OnPlayerInfo_Data, dp);
	}
	
	delete request;
}

public int OnPlayerInfo_Data(const char[] data, DataPack dp)
{
	dp.Reset();
	int userid = dp.ReadCell();
	delete dp;

	char steamId[64];
	bool banned = false;

	Handle jsonData = json_load(data);

	if (jsonData != INVALID_HANDLE)
	{
		if (json_is_array(jsonData))
		{
			Handle jsonData2 = json_array_get(jsonData, 0);
			banned = json_object_get_bool(jsonData2, "is_banned");
			json_object_get_string(jsonData2, "steam_id", steamId, sizeof(steamId));
			delete jsonData2;
		}

		else
		{
			banned = json_object_get_bool(jsonData, "is_banned");
			json_object_get_string(jsonData, "steam_id", steamId, sizeof(steamId));
		}
	}

	delete jsonData;

	int client = GetClientOfUserId(userid);

	if (client > 0 && strlen(steamId) > 0)
	{
		Call_API_OnPlayer_Joined(client, banned);
	}
}
