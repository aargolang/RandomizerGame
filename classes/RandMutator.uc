class RandMutator extends DMMutator;

var array<String> WeaponList;

function PostBeginPlay()
{
    Super.PostBeginPlay();
}

function ModifyPlayer(Pawn Other)
{
    Super.ModifyPlayer(Other);
    Other.Weapon.MaxOutAmmo();
    // log("player modified");
}

///////////////////////////////////////////////////////////////////////////////
// GetRandomWeapon
// 
// TODO: Return a random weapon from the currently valid pool of weapons
///////////////////////////////////////////////////////////////////////////////
function GetRandomWeapon()
{
    local int i;
    i = Rand(WeaponList.Length);
    
    // log("Old Default Weapon: "$DefaultWeaponName);

    DefaultWeaponName = WeaponList[i];

    log("New Default Weapon: "$DefaultWeaponName);

}

/* return what should replace the default weapon
   mutators further down the list override earlier mutators
*/
function Class<Weapon> GetDefaultWeapon()
{
	local Class<Weapon> W;

    // log("GetDefaultWeapon() called");

	if ( NextMutator != None )
	{
		W = NextMutator.GetDefaultWeapon();
		if ( W == None )
			W = MyDefaultWeapon();
	}
	else
		W = MyDefaultWeapon();
	return W;
}

// Put call to GetRandomWeapon here, this gets called for every player spawn
function class<Weapon> MyDefaultWeapon()
{
    // log("MyDefaultWeapon() called");

	GetRandomWeapon();
	DefaultWeapon = class<Weapon>(DynamicLoadObject(DefaultWeaponName, class'Class'));

	return DefaultWeapon;
}



function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    bSuperRelevant = 0;

    if (Other.IsA('UTWeaponPickup'))
    {
        return false;
    }
    else if (Other.IsA('UTAmmoPickup'))
    {
        return false;
    }
    else if(Other.IsA('xWeaponBase'))
    {
        return false;
    }
    else if(Other.IsA('Weapon'))
    {
        // log("check weapon: "$GetItemName(string(Other)));

        if(GetItemName(string(Other)) != GetItemName(string(DefaultWeapon)))
        {
            log("not a valid weapon: "$GetItemName(string(Other)));
            return false;
        }
        log("valid weapon: "$GetItemName(string(Other)));
    }
    return true;
}

defaultproperties
{
    //Test weapon array
    WeaponList[0]="xWeapons.BioRifle"
    WeaponList[1]="xWeapons.LinkGun"
    WeaponList[2]="xWeapons.FlakCannon"
    WeaponList[3]="xWeapons.RocketLauncher"
    // WeaponList[4]="xWeapons.Minigun"
    WeaponList[4]="InstaFlak.SuperFlakCannon"
}
