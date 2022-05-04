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


var int NumResets;
var int ResetInterval;
var int ResetIntervalRemaining;

// event PreBeginPlay()
// {
//     // GetRandomWeapon();
//     Super.PreBeginPlay();
// }

///////////////////////////////////////////////////////////////////////////////
// RestartPlayer (extended from DeathMatch.uc)
///////////////////////////////////////////////////////////////////////////////
function RestartPlayer(Controller aPlayer)
{
    // class'RandMutator'.GetRandomWeapon();
    // aPlayer.Pawn.CreateInventory(BaseMutator.DefaultWeaponName);
    // log("RestartPlayer called");
    
    Super.RestartPlayer(aPlayer);
}

// ///////////////////////////////////////////////////////////////////////////////
// // GetRandomWeapon
// // 
// // TODO: Return a random weapon from the currently valid pool of weapons
// ///////////////////////////////////////////////////////////////////////////////
// function GetRandomWeapon()
// {
//     local String RandomWeaponName;
//     local int i;
//     local int w;

//     // w = ArrayCount(WeaponList);

//     w = WeaponList.Length;
//     i = Rand(w);
//     RandomWeaponName = WeaponList[i];
//     log(RandomWeaponName);

//     BaseMutator.default.DefaultWeaponName = RandomWeaponName;

// }

// ///////////////////////////////////////////////////////////////////////////////
// // InitGame (extended from DeathMatch.uc)
// // 
// // TODO: parse Randomizations and RandomInterval from the setup UI
// // TODO: Set timelimit based on randomizations and time interval
// // NOTE: We might need to completely override the one in DeathMatch.uc and
// //       call Super(UnrealMPGameInfo).InitGame to bypass Deathmatch InitGame
// ///////////////////////////////////////////////////////////////////////////////
// event InitGame( string Options, out string Error )
// {
//     Super.InitGame(Options, Error);
//     GetRandomWeapon();

//     // TimeLimit = Randomizations*RandomizationInterval;
// }

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
        
        local Pawn P;

        Global.Timer();
        Super.Timer(); // might need Super(DeathMatch)

        ResetIntervalRemaining -= 1;

        if (ResetIntervalRemaining <= 0)
        {
            ResetIntervalRemaining = ResetInterval;
            NumResets -= 1;

            foreach DynamicActors(class'Pawn', P)
            {
                P.Weapon.Destroy();
                P.Weapon.Destroyed();
                AddDefaultInventory(P);
            }
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

defaultproperties
{
    GameName="Randomizer"
    Description="FFA except everyone's weapons are randomized every so often for a set amount of rounds"
    GoalScore=25
    NumRounds=1
    bAutoNumBots=True
    TimeLimit=20
    MutatorClass="RandomizerGame.RandMutator"
    // NumResets=40
    ResetInterval=30

    // //Test weapon array
    // WeaponList[0]="xWeapons.BioRifle"
    // WeaponList[1]="xWeapons.LinkGun"
    // WeaponList[2]="xWeapons.FlakCannon"
    // WeaponList[3]="xWeapons.RocketLauncher"
    // WeaponList[4]="InstaFlak.SuperFlakCannon"

}