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


///////////////////////////////////////////////////////////////////////////////
// RestartPlayer (extended from DeathMatch.uc)
///////////////////////////////////////////////////////////////////////////////
function RestartPlayer(Controller aPlayer)
{
    BaseMutator.DefaultWeaponName = GetRanomWeapon();
    Super.RestartPlayer(aPlayer);
}

///////////////////////////////////////////////////////////////////////////////
// GetRandomWeapon
// 
// TODO: Return a random weapon from the currently valid pool of weapons
///////////////////////////////////////////////////////////////////////////////
function Weapon GetRandomWeapon()
{
    Weapon RandomWeapon;

    return RandomWeapon;
}

///////////////////////////////////////////////////////////////////////////////
// InitGame (extended from DeathMatch.uc)
// 
// TODO: parse Randomizations and RandomInterval from the setup UI
// TODO: Set timelimit based on randomizations and time interval
// NOTE: We might need to completely override the one in DeathMatch.uc and
//       call Super(UnrealMPGameInfo).InitGame to bypass Deathmatch InitGame
///////////////////////////////////////////////////////////////////////////////
event InitGame( string Options, out string Error )
{
    Super.InitGame();

    // TimeLimit = Randomizations*RandomizationInterval;
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
}