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
var int ResetInterval;
var int ResetIntervalRemaining;

// This is for when the user uses %X var parsing in the chat
function string ParseChatPercVar(Controller Who, string Cmd)
{
    Log("in randmutator ParseChatPercVar");
    Log(cmd);
    Super.ParseChatPercVar(Who, Cmd);
}


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
            ClientPlaySound(sound'GameSounds.Fanfares.UT2K3Fanfare08');

            log("New gun for: "$string(C));
            //Save current weapon class and destroy weapon
            if(C.Pawn.Weapon != None)
            {
                C.LastPawnWeapon = C.Pawn.Weapon.Class;
                C.Pawn.Weapon.ImmediateStopFire(); //Stop fire on current weapon, fixes sound bug
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
    ResetInterval=10
    bWeaponStay=False

    // //Test weapon array
    // WeaponList[0]="xWeapons.BioRifle"
    // WeaponList[1]="xWeapons.LinkGun"
    // WeaponList[2]="xWeapons.FlakCannon"
    // WeaponList[3]="xWeapons.RocketLauncher"
    // WeaponList[4]="InstaFlak.SuperFlakCannon"

}