/*
	Global API ~ Records

	Author: 	Chuckles, Sikari & Zach47
	Source:		""

*/


// POSTRECORD

bool PostRecord(Handle plugin, PostRecordCallback callback, int client, GlobalMode mode, int stage, int teleports, float time, any data)
{
	char steamid[32];
	if (!GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid)))
	{
		LogError("Failed to POST record because client steam ID was not able to be determined.");
		return false;
	}

	if (gI_mapId < 1)
	{
		LogError("Failed to POST record because current map ID is not set");
		return false;
	}

	char requestUrl[512];
	if(gB_Staging)
	{
		Format(requestUrl, sizeof(requestUrl), "%sstaging.%s", SECURE, API_RECORD);
	}

	else
	{
		Format(requestUrl, sizeof(requestUrl), "%s%s", SECURE, API_RECORD);
	}

	// Create the POST content
	char httpPOSTRecord[512];
	Format(httpPOSTRecord, sizeof(httpPOSTRecord), "{steam_id: \"%s\", map_id: %i, mode: \"%s\",stage: %i, tickrate: %i,teleports: %i,time: %f}", steamid, gI_mapId, gC_GlobalModes[mode], stage, gI_tickRate, teleports, time);

	// Post it
	if (GetFeatureStatus(FeatureType_Native, "SteamWorks_CreateHTTPRequest") == FeatureStatus_Available)
	{
		// Create a datapack with the plugin, callback and the passed data
		DataPack dp = CreateDataPack();
		dp.WriteCell(plugin);
		dp.WriteFunction(callback);
		dp.WriteCell(data);
		dp.WriteString(requestUrl);
		dp.WriteString(httpPOSTRecord);

		Handle postRecord = SteamWorks_CreateHTTPRequest(k_EHTTPMethodPOST, requestUrl);
		
		if (postRecord == INVALID_HANDLE)
		{
			delete dp;
			LogError("Failed to POST record because there was a problem creating the HTTP request.");
			return false;
		}
		
		SteamWorks_SetHTTPRequestHeaderValue(postRecord, "Content-Type", "application/json");
		SteamWorks_SetHTTPRequestHeaderValue(postRecord, "X-ApiKey", gSZ_API_Key);
		SteamWorks_SetHTTPRequestRawPostBody(postRecord, "application/json", httpPOSTRecord, sizeof(httpPOSTRecord));
		SteamWorks_SetHTTPCallbacks(postRecord, OnPostRecordInfo);
		SteamWorks_SetHTTPRequestContextValue(postRecord, dp); // Passing datapack
		SteamWorks_SendHTTPRequest(postRecord);
		
		return true;
	}
	
	return false;
}

public int OnPostRecordInfo(Handle request, bool failure, bool requestSuccessful, EHTTPStatusCode statusCode, DataPack dp)
{
	int status = view_as<int>(statusCode);

	if (failure || !requestSuccessful || status == 404 || status == 500 || status == 503)
	{
		char requestUrl[512], content[512];
		
		dp.Reset();
		Handle plugin = dp.ReadCell();
		Function func = dp.ReadFunction();
		any data = dp.ReadCell();
		dp.ReadString(requestUrl, sizeof(requestUrl));
		dp.ReadString(content, sizeof(content));
		delete dp;
		
		APILog(requestUrl, "POST", status, content);

		if (func != INVALID_FUNCTION)
		{
			// Failure callback
			Call_StartFunction(plugin, func);
			Call_PushCell(true); // Failure
			Call_PushCell(0);
			Call_PushCell(0);
			Call_PushCell(0);
			Call_PushCell(data);
			Call_Finish();
		}
	}
	else
	{
		SteamWorks_GetHTTPResponseBodyCallback(request, OnPostRecordInfo_Data, dp);
	}
	
	delete request;
}

public int OnPostRecordInfo_Data(const char[] response, DataPack dp)
{
	dp.Reset();
	Handle plugin = dp.ReadCell();
	Function func = dp.ReadFunction();
	any data = dp.ReadCell();
	delete dp;

	int place, top100, top100_overall;

	Handle jsonData = json_load(response);

	if (jsonData != INVALID_HANDLE)
	{
		place = json_object_get_int(jsonData, "place");
		top100 = json_object_get_int(jsonData, "top_100");
		top100_overall = json_object_get_int(jsonData, "top_100_overall");
	}

	delete jsonData;

	if (func != INVALID_FUNCTION)
	{
		// Success callback
		Call_StartFunction(plugin, func);
		Call_PushCell(false); // Success
		Call_PushCell(place);
		Call_PushCell(top100);
		Call_PushCell(top100_overall);
		Call_PushCell(data);
		Call_Finish();
	}
}


// GETRECORDTOP

bool GetRecordTop(Handle plugin, GetRecordTopCallback callback, const char[] map, int stage, GlobalMode mode, bool noTeleports, int tickrate, int topcount, any data)
{
	char requestUrl[512];
	if (gB_Staging)
	{
		FormatEx(requestUrl, sizeof(requestUrl), "%sstaging.%s/top?map_name=%s&tickrate=%d&limit=%d&modes_list=%s&stage=%i&has_teleports=%s", SECURE, API_RECORD, map, tickrate, topcount, gC_GlobalModes[mode], stage, noTeleports ? "false" : "true");
	}

	else
	{
		FormatEx(requestUrl, sizeof(requestUrl), "%s%s/top?map_name=%s&tickrate=%d&limit=%d&modes_list=%s&stage=%i&has_teleports=%s", SECURE, API_RECORD, map, tickrate, topcount, gC_GlobalModes[mode], stage, noTeleports ? "false" : "true");
	}

	if (GetFeatureStatus(FeatureType_Native, "SteamWorks_CreateHTTPRequest") == FeatureStatus_Available)
	{
		// Create a datapack with the plugin, callback and the passed data
		DataPack dp = CreateDataPack();
		dp.WriteCell(plugin);
		dp.WriteFunction(callback);
		dp.WriteCell(data);
		dp.WriteString(requestUrl);

		Handle getRecordTop = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, requestUrl);
		
		if (getRecordTop == INVALID_HANDLE)
		{
			delete dp;
			LogError("Failed to GET record top because there was a problem creating the HTTP request.");
			return false;
		}
		
		SteamWorks_SetHTTPRequestHeaderValue(getRecordTop, "Accept", "application/json");
		SteamWorks_SetHTTPCallbacks(getRecordTop, OnRecordTopInfo);
		SteamWorks_SetHTTPRequestContextValue(getRecordTop, dp);
		SteamWorks_SendHTTPRequest(getRecordTop);
		
		return true;
	}
	
	return false;
}

public int OnRecordTopInfo(Handle request, bool failure, bool requestSuccessful, EHTTPStatusCode statusCode, DataPack dp)
{
	int status = view_as<int>(statusCode);

	if (failure || !requestSuccessful || status == 404 || status == 500 || status == 503)
	{
		char requestUrl[512];
		
		dp.Reset();
		Handle plugin = dp.ReadCell();
		Function func = dp.ReadFunction();
		any data = dp.ReadCell();
		dp.ReadString(requestUrl, sizeof(requestUrl));
		delete dp;
		
		APILog(requestUrl, "GET", status);

		if (func != INVALID_FUNCTION)
		{
			// Failure callback
			Call_StartFunction(plugin, func);
			Call_PushCell(true); // Failure
			Call_PushString("");
			Call_PushCell(data);
			Call_Finish();
		}
	}

	else
	{
		SteamWorks_GetHTTPResponseBodyCallback(request, OnRecordTopInfo_Data, dp);
	}
	
	delete request;
}

public int OnRecordTopInfo_Data(const char[] response, DataPack dp)
{
	dp.Reset();
	Handle plugin = dp.ReadCell();
	Function func = dp.ReadFunction();
	any data = dp.ReadCell();
	delete dp;
	
	if (func != INVALID_FUNCTION)
	{
		// Success callback
		Call_StartFunction(plugin, func);
		Call_PushCell(false);
		Call_PushString(response);
		Call_PushCell(data);
		Call_Finish();
	}
}

bool GetRecordTopEx(Handle plugin, GetRecordTopCallback callback, const char[] map, int stage, GlobalMode mode, bool noTeleports, int tickrate, int topcount, any data)
{
	char requestUrl[512];
	if (gB_Staging)
	{
		FormatEx(requestUrl, sizeof(requestUrl), "%sstaging.%s/top?map_name=%s&tickrate=%d&limit=%d&modes_list=%s&stage=%i", SECURE, API_RECORD, map, tickrate, topcount, gC_GlobalModes[mode], stage);
	}

	else
	{
		FormatEx(requestUrl, sizeof(requestUrl), "%s%s/top?map_name=%s&tickrate=%d&limit=%d&modes_list=%s&stage=%i", SECURE, API_RECORD, map, tickrate, topcount, gC_GlobalModes[mode], stage);
	}

	if (noTeleports)
	{
		Format(requestUrl, sizeof(requestUrl), "%s&has_teleports=false", requestUrl);
	}

	if (GetFeatureStatus(FeatureType_Native, "SteamWorks_CreateHTTPRequest") == FeatureStatus_Available)
	{

		// Create a datapack with the plugin, callback and the passed data
		DataPack dp = CreateDataPack();
		dp.WriteCell(plugin);
		dp.WriteFunction(callback);
		dp.WriteCell(data);
		dp.WriteString(requestUrl);

		Handle getRecordTop = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, requestUrl);

		if (getRecordTop == INVALID_HANDLE)
		{
			delete dp;
			LogError("Failed to GET record top EX because there was a problem creating the HTTP request.");
			return false;
		}

		SteamWorks_SetHTTPRequestHeaderValue(getRecordTop, "Accept", "application/json");
		SteamWorks_SetHTTPCallbacks(getRecordTop, OnRecordTopInfoEx);
		SteamWorks_SetHTTPRequestContextValue(getRecordTop, dp);
		SteamWorks_SendHTTPRequest(getRecordTop);

		return true;
	}

	return false;
}

public int OnRecordTopInfoEx(Handle request, bool failure, bool requestSuccessful, EHTTPStatusCode statusCode, DataPack dp)
{
	int status = view_as<int>(statusCode);

	if (failure || !requestSuccessful || status == 404 || status == 500 || status == 503)
	{
		char requestUrl[512];

		dp.Reset();
		Handle plugin = dp.ReadCell();
		Function func = dp.ReadFunction();
		any data = dp.ReadCell();
		dp.ReadString(requestUrl, sizeof(requestUrl));
		delete dp;

		APILog(requestUrl, "GET", status);

		if (func != INVALID_FUNCTION)
		{
			// Failure callback
			Call_StartFunction(plugin, func);
			Call_PushCell(true); // Failure
			Call_PushString("");
			Call_PushCell(data);
			Call_Finish();
		}
	}
	else
	{
		SteamWorks_GetHTTPResponseBodyCallback(request, OnRecordTopInfoEx_Data, dp);
	}

	delete request;
}

public int OnRecordTopInfoEx_Data(const char[] response, DataPack dp)
{
	dp.Reset();
	Handle plugin = dp.ReadCell();
	Function func = dp.ReadFunction();
	any data = dp.ReadCell();
	delete dp;

	if (func != INVALID_FUNCTION)
	{
		// Success callback
		Call_StartFunction(plugin, func);
		Call_PushCell(false);
		Call_PushString(response);
		Call_PushCell(data);
		Call_Finish();
	}
} 