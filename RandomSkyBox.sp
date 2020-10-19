#include <sourcemod>
#include <sdktools>
#include <adt_array>

ArrayList skyBoxes = null;
ConVar cvServerSkyName = null;

public Plugin myinfo = {
	name = "Random SkyBox",
	author = "Mozze",
	description = "",
	version = "",
	url = "t.me/pMozze"
};

public void OnPluginStart() {
	skyBoxes = new ArrayList(ByteCountToCells(64));
	cvServerSkyName = FindConVar("sv_skyname");
}

public void OnMapStart() {
	skyBoxes.Clear();

	File file = OpenFile("addons/sourcemod/configs/RandomSkyBox.cfg", "r");
	if (file != null) {
		char SkyBox[64];

		while (file.ReadLine(SkyBox, sizeof(SkyBox))) {
			TrimString(SkyBox);
			skyBoxes.PushString(SkyBox);
		}

		delete file;
	} else {
		PrintToServer("[RandomSkyBox] > Конфигурационный файл не найден (addons/sourcemod/configs/RandomSkyBox.cfg)");
		return;
	}

	if (skyBoxes.Length < 1) {
		PrintToServer("[RandomSkyBox] > Конфигурационный файл пустой");
		return;
	} else {
		PrintToServer("[RandomSkyBox] > Количество загруженных небес - %d", skyBoxes.Length);
	}

	DirectoryListing directoryListing = OpenDirectory("materials/skybox");
	if (directoryListing != null) {
		char filePath[PLATFORM_MAX_PATH];
  		FileType fileType;

		while (directoryListing.GetNext(filePath, sizeof(filePath), fileType) && fileType == FileType_File) {
			Format(filePath, sizeof(filePath), "materials/skybox/%s", filePath);
			AddFileToDownloadsTable(filePath);
		}

		delete directoryListing;
	}

	char currentSkyBox[64];
	skyBoxes.GetString(skyBoxes.Length == 1 ? 0 : GetRandomInt(0, skyBoxes.Length - 1), currentSkyBox, sizeof(currentSkyBox));
	cvServerSkyName.SetString(currentSkyBox, true, false);
	PrintToServer("[RandomSkyBox] > Установлено небо - %s", currentSkyBox);
}