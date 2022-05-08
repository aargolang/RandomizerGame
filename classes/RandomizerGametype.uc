class RandomizerGametype extends xDeathMatch;
//=============================================================================
// Randomizer: Random weapons every X minutes Y times
// 
// Ending conditions:
//  - Highest number of randomizations have been played (X.Y seconds)
//  - Goal kill score has been reached
//
// TODO: make time limit based on the user input number of randomizations
// TODO: replace game settings options for time limit with # randomizations
// TODO: give player a random weapon at the start of the game
//=============================================================================


#exec OBJ LOAD FILE="..\Sounds\GameSounds.uax"

var int NumResets;
var config int ResetInterval;
var int ResetIntervalRemaining;
var string RandomizerPropDescText[2];
var string RandomizerPropsDisplayText[2];

// This is for when the user uses %X var parsing in the chat
// function string ParseChatPercVar(Controller Who, string Cmd)
// {
//     Log("in randmutator ParseChatPercVar");
//     Log(cmd);
//     Super.ParseChatPercVar(Who, Cmd);
// }

///////////////////////////////////////////////////////////////////////////////
// RestartPlayer (extended from DeathMatch.uc)
///////////////////////////////////////////////////////////////////////////////
function RestartPlayer(Controller aPlayer)
{
    // local int i;
    local class<Weapon> OldWeapon;
    OldWeapon = aPlayer.LastPawnWeapon;
    
    // log("RestartPlayer called");
    
    Super.RestartPlayer(aPlayer);

    while(OldWeapon == BaseMutator.DefaultWeapon)
    {
        log("same gun");
        aPlayer.Pawn.Weapon.Destroy();
        AddGameSpecificInventory(aPlayer.Pawn);
    }
    FillAmmo(aPlayer.Pawn);
}

//Fill ammo to max
function FillAmmo(Pawn P)
{
    local Inventory Inv;

    for(Inv=P.Inventory; Inv!=None; Inv=Inv.Inventory)
    {
        if(Weapon(Inv) != None)
        {
            Weapon(Inv).MaxOutAmmo();
        }
    }
}

///////////////////////////////////////////////////////////////////////////////
// MatchInProgress state (extended from DeathMatch.uc)
// 
// This is mostly copied from DeathMatch.uc
// 
// TODO: implement logic for random weapon switch once all of the other 
//       functionality has been ironed out. See pseudocode in Timer()
///////////////////////////////////////////////////////////////////////////////
State MatchInProgress
{
    function Timer()
    {
        // TODO: Pseodocode of game logic
        //
        // increment local second counter
        // check if we need to swap everyone's guns out
        // if so
        //      remove everyones guns
        //      give everyone a random gun
        //      increment random round counter - working
        //      play sound

        Global.Timer();
        Super.Timer(); // might need Super(DeathMatch)

        ResetIntervalRemaining -= 1;

        if (ResetIntervalRemaining <= 0)
        {
            ResetIntervalRemaining = ResetInterval;
            NumResets -= 1;

            ReRoll();
        }
    }
    function beginstate()
    {
        Super.beginstate();
        NumResets = TimeLimit*(60 / ResetInterval);
        ResetIntervalRemaining = ResetInterval;
        // SetTimer(float(ResetInterval), true);
    }
}

//Replace each player's gun with a new random gun
function ReRoll()
{
    local Controller C;
    local class<Weapon> RandWeapClass;
    local Weapon NewWeapon;
    
    log("Re-rolling...");

    foreach DynamicActors(class'Controller', C)
    {
        if(C.Pawn != None)
        {
            //Play sound announcing switch - not working
            // ClientPlaySound(sound'GameSounds.Fanfares.UT2K3Fanfare08');

            log("New gun for: "$string(C));
            //Save current weapon class and destroy weapon
            if(C.Pawn.Weapon != None)
            {
                C.LastPawnWeapon = C.Pawn.Weapon.Class;
                C.Pawn.Weapon.ImmediateStopFire(); //Stop fire on current weapon, fixes most sound bugs
                C.Pawn.AmbientSound = None; //Not sure why needed, stops minigun winding sound
                C.Pawn.Weapon.Destroy();
                log("Old weapon destroyed");
            }
            //Define new random weapon
            RandWeapClass = BaseMutator.GetDefaultWeapon();
            //Check that new weapon isn't the same as old weapon
            while(RandWeapClass == C.LastPawnWeapon)
            {
                RandWeapClass = BaseMutator.GetDefaultWeapon();
            }
            //Spawn new weapon and give to pawn, with None reference checks for good measure
            if(RandWeapClass != None)
            {
                NewWeapon = Spawn(RandWeapClass,,,C.Pawn.Location);
                log("New weapon created :"$string(NewWeapon));
                if(NewWeapon != None)
                {
                    NewWeapon.GiveTo(C.Pawn);
                    NewWeapon.bCanThrow = False;
                    log("New weapon given to "$string(C));
                }
            }
            //Fill ammo to max
            FillAmmo(C.Pawn);
            log("Ammo maxed");
        }
    }
    log("Done rolling");
}


static function FillPlayInfo(PlayInfo PlayInfo)
{
    local int i;
	Super(Info).FillPlayInfo(PlayInfo);  // Always begin with calling parent

    // Randomizer settings
	PlayInfo.AddSetting(default.GameGroup,   "ResetInterval",  GetDisplayText("ResetInterval"),  0,        1, "Text","3;1:600"    ,,,);

    // Duplicated settings from DeathMatch, UnrealMPGameInfo, GameInfo
    PlayInfo.AddSetting(default.BotsGroup,   "GameDifficulty",			GetDisplayText("GameDifficulty"), 		0, 2, "Select", default.GIPropsExtras[0], "Xb");
	PlayInfo.AddSetting(default.GameGroup,   "GoalScore",				GetDisplayText("GoalScore"), 			0, 0, "Text",     "3;0:999");
	PlayInfo.AddSetting(default.GameGroup,   "TimeLimit",				GetDisplayText("TimeLimit"), 			0, 0, "Text",     "3;0:999");
	PlayInfo.AddSetting(default.GameGroup,   "MaxLives",				GetDisplayText("MaxLives"), 			0, 0, "Text",     "3;0:999");
	PlayInfo.AddSetting(default.RulesGroup,  "bAllowWeaponThrowing",	GetDisplayText("bAllowWeaponThrowing"), 1, 0, "Check",             ,            ,    ,True);
	PlayInfo.AddSetting(default.RulesGroup,  "bAllowBehindView",		GetDisplayText("bAllowBehindview"), 	1, 0, "Check",             ,            ,True,True);
	PlayInfo.AddSetting(default.RulesGroup,  "bWeaponShouldViewShake",	GetDisplayText("bWeaponShouldViewShake"),1, 0, "Check",            ,            ,    ,True);
	PlayInfo.AddSetting(default.ServerGroup, "bEnableStatLogging",		GetDisplayText("bEnableStatLogging"), 	0, 1, "Check",             ,            ,True);
	PlayInfo.AddSetting(default.ServerGroup, "bAdminCanPause",			GetDisplayText("bAdminCanPause"), 		1, 1, "Check",             ,            ,True,True);
	PlayInfo.AddSetting(default.ServerGroup, "MaxSpectators",			GetDisplayText("MaxSpectators"), 		1, 1, "Text",      "3;0:32",            ,True,True);
	PlayInfo.AddSetting(default.ServerGroup, "MaxPlayers",				GetDisplayText("MaxPlayers"), 			0, 1, "Text",      "3;0:32",            ,True);
	PlayInfo.AddSetting(default.ServerGroup, "MaxIdleTime",			GetDisplayText("MaxIdleTime"), 			0, 1, "Text",      "3;0:300",            ,True,True);
    gameinfoStartStuff(PlayInfo); // put all of the GameInfo duplicate garbage here
	PlayInfo.AddSetting(default.BotsGroup,  "MinPlayers",         default.MPGIPropsDisplayText[i++], 0,   0,   "Text",            "3;0:32");
	PlayInfo.AddSetting(default.GameGroup,  "EndTimeDelay",       default.MPGIPropsDisplayText[i++], 1,   1,   "Text",                    ,     ,     , True);
	PlayInfo.AddSetting(default.BotsGroup,  "BotMode",			   default.MPGIPropsDisplayText[i++], 30,  1, "Select", default.BotModeText);
	PlayInfo.AddSetting(default.RulesGroup, "bAllowPrivateChat",  default.MPGIPropsDisplayText[i++], 254, 1,  "Check",                    , "Xv", True, True);
    if ( !Default.bTeamGame )
		PlayInfo.AddSetting(default.BotsGroup,   "bAdjustSkill",        GetDisplayText("bAdjustSkill"),        0,    2, "Check",             ,,    ,True);
	PlayInfo.AddSetting(default.GameGroup,   "SpawnProtectionTime", GetDisplayText("SpawnProtectionTime"), 2,    1,  "Text", "8;0.0:30.0",,    ,True);
	PlayInfo.AddSetting(default.GameGroup,   "LateEntryLives",      GetDisplayText("LateEntryLives"),     50,    1,  "Text",          "3",,True,True);
	PlayInfo.AddSetting(default.GameGroup,   "bColoredDMSkins",     GetDisplayText("bColoredDMSkins"),     1,    1, "Check",             ,,    ,True);
	PlayInfo.AddSetting(default.GameGroup,   "bAllowPlayerLights",  GetDisplayText("bAllowPlayerLights"),  1,    1, "Check",             ,,    ,True);
	PlayInfo.AddSetting(default.RulesGroup,  "bAllowTrans",         GetDisplayText("bAllowTrans"),         0,    1, "Check",             ,,    ,True);
	PlayInfo.AddSetting(default.RulesGroup,  "bAllowTaunts",        GetDisplayText("bAllowTaunts"),        1,    1, "Check",             ,,    ,True);
	PlayInfo.AddSetting(default.RulesGroup,  "bForceRespawn",       GetDisplayText("bForceRespawn"),       0,    1, "Check",             ,,True,True);
	PlayInfo.AddSetting(default.RulesGroup,  "bPlayersMustBeReady", GetDisplayText("bPlayersMustBeReady"), 1,    1, "Check",             ,,True,True);
	PlayInfo.AddSetting(default.ServerGroup, "MinNetPlayers",       GetDisplayText("MinNetPlayers"),       100,  1,  "Text",     "3;0:32",,True,True);
	PlayInfo.AddSetting(default.ServerGroup, "NetWait",             GetDisplayText("NetWait"),             200,  1,  "Text",     "3;0:60",,True,True);
	PlayInfo.AddSetting(default.ServerGroup, "RestartWait",         GetDisplayText("RestartWait"),         200,  1,  "Text",     "3;0:60",,True,True);
	class'MasterServerUplink'.static.FillPlayInfo(PlayInfo);

    PlayInfo.PopClass();
}

///////////////////////////////////////////////////////////////////////////////
// GameInfoStartStuff
//
// This logic is duplicated from GameInfo in order to get rid of bWeapnStay
///////////////////////////////////////////////////////////////////////////////
static function gameinfoStartStuff(PlayInfo PlayInfo)
{

	if (default.GameReplicationInfoClass != None)
	{
		default.GameReplicationInfoClass.static.FillPlayInfo(PlayInfo);
		PlayInfo.PopClass();
	}

	if (default.VoiceReplicationInfoClass != None)
	{
		default.VoiceReplicationInfoClass.static.FillPlayInfo(PlayInfo);
		PlayInfo.PopClass();
	}

	if (default.BroadcastClass != None)
		default.BroadcastClass.static.FillPlayInfo(PlayInfo);

	else class'BroadcastHandler'.static.FillPlayInfo(PlayInfo);

	PlayInfo.PopClass();

	if (class'Engine.GameInfo'.default.VotingHandlerClass != None)
 	{
	 	class'Engine.GameInfo'.default.VotingHandlerClass.static.FillPlayInfo(PlayInfo);
	 	PlayInfo.PopClass();
	}
	else
		log("GameInfo::FillPlayInfo class'Engine.GameInfo'.default.VotingHandlerClass = None");
}

static function string GetDisplayText(string PropName)
{
	switch (PropName)
	{
		case "ResetInterval":            return default.RandomizerPropsDisplayText[0];
	}

	return Super.GetDisplayText(PropName);
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "ResetInterval":            return default.RandomizerPropDescText[0];
	}

	return Super.GetDescriptionText(PropName);
}

defaultproperties
{
    GameName="Randomizer"
    Description="FFA except everyone's weapons are randomized every so often for a set amount of rounds"
    GoalScore=25
    NumRounds=1
    bAutoNumBots=True
    TimeLimit=20
    MutatorClass="RandomizerGame.RandMutator"
    ResetInterval=10
    bWeaponStay=False

    RandomizerPropDescText[0]="Time between randomizing all weapons in minutes"
    RandomizerPropsDisplayText[0]="Randomization Interval"
}