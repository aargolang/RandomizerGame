class RandMutator extends DMMutator;

// var String WeaponList[5];

// function GetRandomWeapon()
// {
//     local String RandomWeaponName;
//     local int i;
//     local int w;

//     w = ArrayCount(WeaponList);

//     i = Rand(w);
//     RandomWeaponName = WeaponList[i];

//     DefaultWeaponName = RandomWeaponName;

// }

// event PreBeginPlay()
// {
//     GetRandomWeapon();
//     Super.PreBeginPlay();
// }

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    local int i;
    local int w;
    bSuperRelevant = 0;

    if (Other.IsA('UTWeaponPickup'))
    {
        return false;
    }
    if (Other.IsA('UTAmmoPickup'))
    {
        return false;
    }
    if(Other.IsA('xWeaponBase'))
    {
        return false;
    }
    if(Other.IsA('Weapon'))
    {
        w = ArrayCount(class'RandomizerGametype'.default.WeaponList);

        for(i=0; i <= w; i++)
        {
            if(GetItemName(string(Weapon(Other))) != class'RandomizerGametype'.WeaponList[i])
            {
            return false;
            }
        }
    }
    return true;
}

defaultproperties
{
    //Test weapon array
    // WeaponList[0]="xWeapons.AssaultRifle"
    // WeaponList[1]="xWeapons.LinkGun"
    // WeaponList[2]="xWeapons.FlakCannon"
    // WeaponList[3]="xWeapons.RocketLauncher"
    // WeaponList[4]="InstaFlak.SuperFlakCannon"
}
