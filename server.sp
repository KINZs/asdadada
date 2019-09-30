/*
	Global API ~ Server

	Author: 	Chuckles, Sikari & Zach47
	Source:		""

*/

public void GetAuthStatus(const char[] auth, Handle plugin, GetAuthStatusCallback func)
{
	char requestUrl[512];
	if (gB_Staging)
	{
		Format(requestUrl, sizeof(requestUrl), "%sstaging.%s", SECURE, API_STATUS);
	}

	else
	{
		Format(requestUrl, sizeof(requestUrl), "%s%s", SECURE, API_STATUS);
	}

	if (GetFeatureStatus(FeatureType_Native, "SteamWorks_CreateHTTPRequest") == FeatureStatus_Available)
	{
		// Create a datapack with the plugin, callback and the passed data
		DataPack dp = CreateDataPack();
		dp.WriteFunction(func);
		dp.WriteCell(plugin);
		dp.WriteString(requestUrl);

		Handle authStatus = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, requestUrl);
		
		if (authStatus == INVALID_HANDLE)
		{
			delete dp;
			LogError("Failed to GET auth status because there was a problem creating the HTTP request.");
			return;
		}

		SteamWorks_SetHTTPRequestHeaderValue(authStatus, "X-ApiKey", gSZ_API_Key);
		SteamWorks_SetHTTPCallbacks(authStatus, OnAuthStatusInfo);
		SteamWorks_SetHTTPRequestContextValue(authStatus, dp);
		SteamWorks_SendHTTPRequest(authStatus);
	}
}

public int OnAuthStatusInfo(Handle request, bool failure, bool requestSuccessful, EHTTPStatusCode statusCode, DataPack dp)
{
	int status = view_as<int>(statusCode);

	if (failure || !requestSuccessful || status == 404 || status == 500 || status == 503)
	{
		char requestUrl[512];

		dp.Reset();
		Function func = dp.ReadFunction();
		Handle plugin = dp.ReadCell();
		dp.ReadString(requestUrl, sizeof(requestUrl));
		delete dp;

		APILog(requestUrl, "GET", status);

		if (func != INVALID_FUNCTION)
		{
			Call_StartFunction(plugin, func);
			Call_PushCell(true);
			Call_PushCell(false);
			Call_Finish();
		}
	}

	else
	{
		SteamWorks_GetHTTPResponseBodyCallback(request, OnAuthStatusInfo_Data, dp);
	}
	
	delete request;
}

public int OnAuthStatusInfo_Data(const char[] data, DataPack dp)
{
	dp.Reset();
	Function func = dp.ReadFunction();
	Handle plugin = view_as<Handle>(dp.ReadCell());
	delete dp;

	bool authenticated = false;
	
	Handle jsonData = json_load(data);

	if (jsonData != INVALID_HANDLE)
	{
		authenticated = json_object_get_bool(jsonData, "isValid");
	}

	delete jsonData;
	
	if (func != INVALID_FUNCTION)
	{
		Call_StartFunction(plugin, func);
		Call_PushCell(false);
		Call_PushCell(authenticated);
		Call_Finish();
	}
}

public void GetModeInfo(Handle plugin, GetModeInfoCallback func, GlobalMode mode, any data)
{
	char requestUrl[512];
	if (gB_Staging)
	{
		Format(requestUrl, sizeof(requestUrl), "%sstaging.%s/name/%s", SECURE, API_MODES, gC_GlobalModes[mode]);
	}

	else
	{
		Format(requestUrl, sizeof(requestUrl), "%s%s/name/%s", SECURE, API_MODES, gC_GlobalModes[mode]);
	}

	if (GetFeatureStatus(FeatureType_Native, "SteamWorks_CreateHTTPRequest") == FeatureStatus_Available)
	{
		// Create a datapack with the plugin, callback and the passed data
		DataPack dp = CreateDataPack();
		dp.WriteFunction(func);
		dp.WriteCell(plugin);
		dp.WriteCell(data);
		dp.WriteString(requestUrl);

		Handle ModeInfo = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, requestUrl);
		
		if (ModeInfo == INVALID_HANDLE) 
		{
			delete dp;
			LogError("Failed to GET modeinfo because there was a problem creating the HTTP request.");
			return;
		}
		
		SteamWorks_SetHTTPRequestHeaderValue(ModeInfo, "X-ApiKey", gSZ_API_Key);
		SteamWorks_SetHTTPCallbacks(ModeInfo, OnModeInfoInfo);
		SteamWorks_SetHTTPRequestContextValue(ModeInfo, dp);
		SteamWorks_SendHTTPRequest(ModeInfo);
	}
}

public int OnModeInfoInfo(Handle request, bool failure, bool requestSuccessful, EHTTPStatusCode statusCode, DataPack dp)
{
	int status = view_as<int>(statusCode);

	if (failure || !requestSuccessful || status == 404 || status == 500 || status == 503)
	{
		char requestUrl[512];

		dp.Reset();
		Function func = dp.ReadFunction();
		Handle plugin = dp.ReadCell();
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
			Call_PushCell(-1);
			Call_PushString("");
			Call_PushCell(data);
			Call_Finish();
		}
	}

	else
	{
		SteamWorks_GetHTTPResponseBodyCallback(request, OnModeInfoInfo_Data, dp);
	}
	
	delete request;
}

public int OnModeInfoInfo_Data(const char[] response, DataPack dp)
{
	dp.Reset();
	Function func = dp.ReadFunction();
	Handle plugin = dp.ReadCell();
	any data = dp.ReadCell();
	delete dp;

	char name[128];
	char latest_version_description[128];
	
	Handle jsonData = json_load(response);
	int latest_version;

	if (jsonData != INVALID_HANDLE)
	{
		json_object_get_string(jsonData, "name", name, sizeof(name));
		latest_version = json_object_get_int(jsonData, "latest_version");
		json_object_get_string(jsonData, "latest_version_description", latest_version_description, sizeof(latest_version_description));
	}

	delete jsonData;

	if (func != INVALID_FUNCTION)
	{
		Call_StartFunction(plugin, func);
		Call_PushCell(false);
		Call_PushString(name);
		Call_PushCell(latest_version);
		Call_PushString(latest_version_description);
		Call_PushCell(data);
		Call_Finish();
	}
}


	
	