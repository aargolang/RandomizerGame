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


#exec OBJ LOAD FILE="..\Sounds\NewWeaponSounds.uax"

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
    // local int i;
    local class<Weapon> OldWeapon;
    OldWeapon = aPlayer.LastPawnWeapon;
    
    // log("RestartPlayer called");
    
    Super.RestartPlayer(aPlayer);

    while(OldWeapon == BaseMutator.DefaultWeapon)
    {
        log("same gun");
        aPlayer.Pawn.Weapon.Destroy();
        AddDefaultInventory(aPlayer.Pawn);
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
        
        // local Controller C;
        // local class<Weapon> OldWeapon;
        // local int i;

        Global.Timer();
        Super.Timer(); // might need Super(DeathMatch)

        ResetIntervalRemaining -= 1;

        if (ResetIntervalRemaining <= 0)
        {
            ResetIntervalRemaining = ResetInterval;
            NumResets -= 1;

            ReRoll();
            
            // foreach DynamicActors(class'Controller', C)
            // {
            //     // PlaySound(sound'NewWeaponSounds.WeaponsLocker_01');
            //     if(C.Pawn != None)
            //     {
            //         OldWeapon = C.LastPawnWeapon;

            //         C.Pawn.Weapon.Destroy();
            //         AddDefaultInventory(C.Pawn);
            //         while(OldWeapon == BaseMutator.DefaultWeapon)
            //         {
            //             C.Pawn.Weapon.Destroy();
            //             AddDefaultInventory(C.Pawn);
            //         }
            //         FillAmmo(C.Pawn);
            //     }
            // }
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
    local class<Weapon> OldWeapon;
    
    log("re-rolling...");

    PlaySound(sound'NewWeaponSounds.WeaponsLocker_01');

    foreach DynamicActors(class'Controller', C)
    {
        // PlaySound(sound'NewWeaponSounds.WeaponsLocker_01');
        if(C.Pawn != None)
        {
            log("new gun for: "$string(C));
            OldWeapon = C.LastPawnWeapon;

            C.Pawn.Weapon.Destroy();
            AddGameSpecificInventory(C.Pawn);
            while(OldWeapon == BaseMutator.DefaultWeapon)
            {
                log("same gun: "$string(OldWeapon));
                if(C.Pawn.Weapon != None)
                {
                    C.Pawn.Weapon.Destroy();
                }
                AddGameSpecificInventory(C.Pawn);
            }
            FillAmmo(C.Pawn);
        }
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
    bWeaponStay=False

    // //Test weapon array
    // WeaponList[0]="xWeapons.BioRifle"
    // WeaponList[1]="xWeapons.LinkGun"
    // WeaponList[2]="xWeapons.FlakCannon"
    // WeaponList[3]="xWeapons.RocketLauncher"
    // WeaponList[4]="InstaFlak.SuperFlakCannon"

}