/*
	Global API ~ Map

	Author: 	Chuckles, Sikari & Zach47
	Source:		""

*/

public void LoadMap()
{
	char mapPath[PLATFORM_MAX_PATH];
	char mapDisplayName[64];

	GetCurrentMap(mapPath, sizeof(mapPath));
	GetMapDisplayName(mapPath, mapDisplayName, sizeof(mapDisplayName));

	int fileSize;
	Format(mapPath, sizeof(mapPath), "maps/%s.bsp", mapPath);
	fileSize = FileSize(mapPath);

	FormatEx(gSZ_mapPath, sizeof(gSZ_mapPath), "%s", mapPath);
	FormatEx(gSZ_mapName, sizeof(gSZ_mapName), "%s", mapDisplayName);

	GetMapID(mapDisplayName, fileSize);
}

public void GetMapID(const char[] map, int fileSize)
{
	char requestUrl[512];
	if (gB_Staging)
	{
		Format(requestUrl, sizeof(requestUrl), "%sstaging.%s?name=%s&filesize=%d", SECURE, API_MAP, map, fileSize);
	}

	else
	{
		Format(requestUrl, sizeof(requestUrl), "%s%s?name=%s&filesize=%d", SECURE, API_MAP, map, fileSize);
	}

	if (GetFeatureStatus(FeatureType_Native, "SteamWorks_CreateHTTPRequest") == FeatureStatus_Available)
	{

		DataPack dp = CreateDataPack();
		dp.WriteString(requestUrl);
		
		Handle getMap = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, requestUrl);

		if (getMap == INVALID_HANDLE)
		{
			delete dp;
			gB_mapGlobalStatus = false;
			LogError("Failed to GET map id because there was a problem creating the HTTP request.");
			return;
		}
		
		SteamWorks_SetHTTPRequestHeaderValue(getMap, "Accept", "application/json");
		SteamWorks_SetHTTPCallbacks(getMap, OnMapInfo);
		SteamWorks_SetHTTPRequestContextValue(getMap, dp);
		SteamWorks_SendHTTPRequest(getMap);
	}
}

public int OnMapInfo(Handle request, bool failure, bool requestSuccessful, EHTTPStatusCode statusCode, DataPack dp)
{
	int status = view_as<int>(statusCode);

	if (failure || !requestSuccessful || status == 404 || status == 500 || status == 503)
	{
		char requestUrl[512];

		dp.Reset();
		dp.ReadString(requestUrl, sizeof(requestUrl));
		delete dp;

		APILog(requestUrl, "GET", status);
	}
	
	else
	{
		delete dp;
		SteamWorks_GetHTTPResponseBodyCallback(request, OnMapInfo_Data);
	}

	delete request;
}

public int OnMapInfo_Data(const char[] data)
{
	Handle jsonData = json_load(data);
	Handle jsonData2 = json_array_get(jsonData, 0);

	if (jsonData != INVALID_HANDLE)
	{
		if(jsonData2 != INVALID_HANDLE)
		{
			gI_mapId = json_object_get_int(jsonData2, "id");
			gI_mapTier = json_object_get_int(jsonData2, "difficulty");
			gI_mapfileSize = json_object_get_int(jsonData2, "filesize");
			gB_mapGlobalStatus = json_object_get_bool(jsonData2, "validated");
		}
	}

	delete jsonData;
	delete jsonData2;
}

