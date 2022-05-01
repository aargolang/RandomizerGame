class RandomizerGametype extends xDeathMatch;
//=============================================================================
// Randomizer: Random weapons every X minutes Y times
// 
// Ending conditions:
//  - Highest number of randomizer rounds have been played (X.Y seconds)
//  - Goal kill score has been reached
//
// TODO: remove the TimeLimit condition of ending a match in
//      - StartMatch()
//      - Reset()
//      - InitGame()
//      - GetServerDetails()
//      - InitReplicationInfo()
//      - EndGame()
//      - MatchInProgress
// TODO: remove RemainingTime from:
//      - PostBeginPlay()
//      - Reset()
//      - JustStarted()
//      - CheckReady()
//      - InitGame()
//      - StartMatch()
//      - MatchInProgress
// TODO: write Time() method in MatchInProgress state
// TODO: convert this class to extend DeathMatch instead of xDeathMatch
//      - Port needed logic from xDeathMatch
//=============================================================================



// Removed setting time to 10.0
// TODO: remove the notion of setting the remaining time
function StartMatch()
{
    local bool bTemp;
	local int Num;

    GotoState('MatchInProgress');
    if ( Level.NetMode == NM_Standalone )
        RemainingBots = InitialBots;
    else
        RemainingBots = 0;
    GameReplicationInfo.RemainingMinute = RemainingTime;
    Super.StartMatch();
    bTemp = bMustJoinBeforeStart;
    bMustJoinBeforeStart = false;
    while ( NeedPlayers() && (Num<16) )
    {
		if ( AddBot() )
			RemainingBots--;
		Num++;
    }
    bMustJoinBeforeStart = bTemp;
    log("START MATCH");
}

///////////////////////////////////////////////////////////////////////////////
// MatchInProgress state
// 
// This is mostly copied from xDeathMatch.uc
///////////////////////////////////////////////////////////////////////////////
State MatchInProgress
{
    function Timer()
    {
        // Pseodocode
        //
        // increment local second counter
        // check if we need to swap everyone's guns out
        // if so
        //      remove everyones guns
        //      give everyone a random gun
        //      increment random round counter
        //      play sound
        Super.Timer();
        Global.Timer(); // calls GameInfo.Timer()
		if (!bFinalStartup)
		{
			bFinalStartup = true;
			PlayStartupMessage();
		}
        if (bForceRespawn)
        {
            For ( P=Level.ControllerList; P!=None; P=P.NextController )
            {
                if((P.Pawn == None) && 
                    P.IsA('PlayerController') && 
                    !P.PlayerReplicationInfo.bOnlySpectator)
                {
                    PlayerController(P).ServerReStartPlayer();
                }
            }
        }
        if (NeedPlayers() && AddBot() && (RemainingBots > 0) )
        {
			RemainingBots--;
        }

        if ( bOverTime )
        {
			EndGame(None,"TimeLimit");
        }
        else if ( TimeLimit > 0 )
        {
            GameReplicationInfo.bStopCountDown = false;
            RemainingTime--;
            GameReplicationInfo.RemainingTime = RemainingTime;
            if ( RemainingTime % 60 == 0 )
                GameReplicationInfo.RemainingMinute = RemainingTime;
            if ( RemainingTime <= 0 )
                EndGame(None,"TimeLimit");
        }
        else if ( (MaxLives > 0) && (NumPlayers + NumBots != 1) )
			CheckMaxLives(none);

        ElapsedTime++;
        GameReplicationInfo.ElapsedTime = ElapsedTime;
    }

    function beginstate()
    {
		local PlayerReplicationInfo PRI;

		ForEach DynamicActors(class'PlayerReplicationInfo',PRI)
			PRI.StartTime = 0;
		ElapsedTime = 0;
		bWaitingToStartMatch = false;
        StartupStage = 5;
        PlayStartupMessage();
        StartupStage = 6;
    }
}

defaultproperties
{
    GameName="Randomizer"
    Description="FFA except everyone's weapons are randomized every so often for a set amount of rounds"
    GoalScore=1
    bAutoNumBots=True
    TimeLimit=20
    // MapListType="XInterface.MapListDeathMatch"
    // HUDType="XInterface.HudCDeathMatch"
	// DeathMessageClass=class'XGame.xDeathMessage'

    // ScreenShotName="UT2004Thumbnails.DMShots"
    // DecoTextName="XGame.Deathmatch"

    // Acronym="DM"
    // MapPrefix="DM"
    // DefaultEnemyRosterClass="XGame.xDMRoster"
}