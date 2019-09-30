/*
	Global API ~ Bans

	Author: 	Chuckles, Sikari & Zach47
	Source:		""

*/

public void GlobalAPI_OnPlayer_Joined(int client, bool banned)
{
	if (banned && gCV_KickIfBanned.BoolValue)
	{
		KickClient(client, "You're globally banned. Please see http://www.kzstats.com/bans/ for more information.");
	}
}

public int PostAPIBanPlayer(Handle plugin, PostBanCallback func, int client, const char[] ban_type, const char[] notes, const char[] stats, any data)
{
	char steamid[32], ip[64];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	GetClientIP(client, ip, sizeof(ip));

	char requestUrl[512];
	if (gB_Staging)
	{
		Format(requestUrl, sizeof(requestUrl), "%sstaging.%s", SECURE, API_BAN);
	}

	else
	{
		Format(requestUrl, sizeof(requestUrl), "%s%s", SECURE, API_BAN);
	}

	char httpPOSTRecord[512];
	Format(httpPOSTRecord, sizeof(httpPOSTRecord), "{steam_id: \"%s\", ban_type: \"%s\", notes: \"%s\", stats: \"%s\", ip: \"%s\"}", steamid, ban_type, notes, stats, ip);
	
	if (GetFeatureStatus(FeatureType_Native, "SteamWorks_CreateHTTPRequest") == FeatureStatus_Available)
	{
		DataPack dp = CreateDataPack();
		dp.WriteCell(plugin);
		dp.WriteFunction(func);
		dp.WriteCell(data);
		dp.WriteString(requestUrl);
		dp.WriteString(httpPOSTRecord);

		Handle postBan = SteamWorks_CreateHTTPRequest(k_EHTTPMethodPOST, requestUrl);
		
		if (postBan == INVALID_HANDLE)
		{
			delete dp;
			PrintToServer("Failed to POST ban because there was a problem creating the HTTP request.");
			return false;
		}
		
		SteamWorks_SetHTTPRequestHeaderValue(postBan, "Content-Type", "application/json");
		SteamWorks_SetHTTPRequestHeaderValue(postBan, "X-ApiKey", gSZ_API_Key);
		SteamWorks_SetHTTPRequestRawPostBody(postBan, "application/json", httpPOSTRecord, sizeof(httpPOSTRecord));
		SteamWorks_SetHTTPCallbacks(postBan, OnPostBanInfo);
		SteamWorks_SetHTTPRequestContextValue(postBan, dp);
		SteamWorks_SendHTTPRequest(postBan);
		
		return true;
	}
	return false;
}

public int OnPostBanInfo(Handle request, bool failure, bool requestSuccessful, EHTTPStatusCode statusCode, DataPack dp)
{
	int status = view_as<int>(statusCode);

	if (failure || !requestSuccessful || status == 404 || status == 500 || status == 503) 
	{
		char requestUrl[512], content[512];

		dp.Reset();
		Handle plugin = view_as<Handle>(dp.ReadCell());
		Function func = dp.ReadFunction();
		any data = dp.ReadCell();
		dp.ReadString(requestUrl, sizeof(requestUrl));
		dp.ReadString(content, sizeof(content));
		delete dp;

		APILog(requestUrl, "POST", status, content);

		if (func != INVALID_FUNCTION)
		{
			Call_StartFunction(plugin, func);
			Call_PushCell(true);
			Call_PushCell(data);
			Call_Finish();
		}
	}

	else
	{
		SteamWorks_GetHTTPResponseBodyCallback(request, OnPostBanInfo_Data, dp);
	}
	
	delete request;
}

public int OnPostBanInfo_Data(const char[] response, any datapack)
{
	DataPack dp = view_as<DataPack>(datapack);
	dp.Reset();
	Handle plugin = view_as<Handle>(dp.ReadCell());
	Function func = dp.ReadFunction();
	any data = dp.ReadCell();
	delete dp;

	if (func != INVALID_FUNCTION)
	{
		Call_StartFunction(plugin, func);
		Call_PushCell(false);
		Call_PushCell(data);
		Call_Finish();
	}
}