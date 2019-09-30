/*
	Global API - Jumpstats Module ~ API Calls - Get Jumpstat Top

	Author: 	Chuckles, Sikari & Zach47
	Source:		""

*/

int GetJumpstatTop(Handle plugin, GetJumpstatTopCallback callback, APIJumptype jumpType, any data)
{
	char requestUrl[512];
	if (gB_Staging)
	{
		Format(requestUrl, sizeof(requestUrl), "%sstaging.%s/%s/top30", SECURE, API_JUMPSTATS, gC_JumpTypePhrases[jumpType]);
	}

	else
	{
		Format(requestUrl, sizeof(requestUrl), "%s%s/%s/top30", SECURE, API_JUMPSTATS, gC_JumpTypePhrases[jumpType]);
	}
	
	if (GetFeatureStatus(FeatureType_Native, "SteamWorks_CreateHTTPRequest") == FeatureStatus_Available)
	{

		DataPack dp = CreateDataPack();
		dp.WriteCell(plugin);
		dp.WriteFunction(callback);
		dp.WriteCell(data);
		dp.WriteString(requestUrl);

		Handle getJumpTop = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, requestUrl);
		
		if (getJumpTop == INVALID_HANDLE)
		{
			delete dp;
			LogError("Failed to GET jumpstats top because there was a problem creating the HTTP request.");
			return;
		}
		
		SteamWorks_SetHTTPRequestHeaderValue(getJumpTop, "Accept", "application/json");
		SteamWorks_SetHTTPCallbacks(getJumpTop, OnJumpTopInfo);
		SteamWorks_SetHTTPRequestContextValue(getJumpTop, dp);
		SteamWorks_SendHTTPRequest(getJumpTop);
	}
}

public int OnJumpTopInfo(Handle request, bool failure, bool requestSuccessful, EHTTPStatusCode statusCode, DataPack dp)
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

		if (gI_Logging >= 1)
		{
			APILog(requestUrl, "GET", status);
		}
		
		if (func != INVALID_FUNCTION)
		{
			Call_StartFunction(plugin, func);
			Call_PushCell(true); // Failure
			Call_PushString("");
			Call_PushCell(data);
			Call_Finish();
		}
	}
	
	else
	{
		SteamWorks_GetHTTPResponseBodyCallback(request, OnJumpTopInfo_Data, dp);
	}
	
	delete request;
}

public int OnJumpTopInfo_Data(const char[] response, DataPack dp)
{
	dp.Reset();
	Handle plugin = dp.ReadCell();
	Function func = dp.ReadFunction();
	any data = dp.ReadCell();
	delete dp;
	
	if (func != INVALID_FUNCTION)
	{
		Call_StartFunction(plugin, func);
		Call_PushCell(false); // Success
		Call_PushString(response);
		Call_PushCell(data);
		Call_Finish();
	}
}

int GetJumpstatTopEx(Handle plugin, GetJumpstatTopCallback callback, APIJumptype jumpType, bool bind, any data)
{
	char requestUrl[512];
	if (gB_Staging)
	{
		Format(requestUrl, sizeof(requestUrl), "%sstaging.%s/%s/top?is_crouch_bind=%s&is_crouch_boost=%s", SECURE, API_JUMPSTATS, gC_JumpTypePhrases[jumpType], bind ? "true" : "false", bind ? "true" : "false");
	}

	else
	{
		Format(requestUrl, sizeof(requestUrl), "%s%s/%s/top?is_crouch_bind=%s&is_crouch_boost=%s", SECURE, API_JUMPSTATS, gC_JumpTypePhrases[jumpType], bind ? "true" : "false", bind ? "true" : "false");
	}

	if (GetFeatureStatus(FeatureType_Native, "SteamWorks_CreateHTTPRequest") == FeatureStatus_Available)
	{
		DataPack dp = CreateDataPack();
		dp.WriteCell(plugin);
		dp.WriteFunction(callback);
		dp.WriteCell(data);
		dp.WriteString(requestUrl);

		Handle getJumpTopEx = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, requestUrl);
		
		if (getJumpTopEx == INVALID_HANDLE)
		{
			delete dp;
			LogError("Failed to GET jumpstats top because there was a problem creating the HTTP request.");
			return;
		}

		SteamWorks_SetHTTPRequestHeaderValue(getJumpTopEx, "Accept", "application/json");
		SteamWorks_SetHTTPCallbacks(getJumpTopEx, OnJumpTopExInfo);
		SteamWorks_SetHTTPRequestContextValue(getJumpTopEx, dp);
		SteamWorks_SendHTTPRequest(getJumpTopEx);
	}
}

public int OnJumpTopExInfo(Handle request, bool failure, bool requestSuccessful, EHTTPStatusCode statusCode, DataPack dp)
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
			Call_StartFunction(plugin, func);
			Call_PushCell(true); // Failure
			Call_PushString("");
			Call_PushCell(data);
			Call_Finish();
		}
	}

	else
	{
		SteamWorks_GetHTTPResponseBodyCallback(request, OnJumpTopExInfo_Data, dp);
	}

	delete request;
}

public int OnJumpTopExInfo_Data(const char[] response, DataPack dp)
{
	dp.Reset();
	Handle plugin = dp.ReadCell();
	Function func = dp.ReadFunction();
	any data = dp.ReadCell();
	delete dp;

	if (func != INVALID_FUNCTION)
	{
		Call_StartFunction(plugin, func);
		Call_PushCell(false); // Success
		Call_PushString(response);
		Call_PushCell(data);
		Call_Finish();
	}
}
