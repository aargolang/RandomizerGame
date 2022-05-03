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

event PreBeginPlay()
{
    // DefaultWeaponName = class'RandomizerGametype'.default.WeaponList[Rand(class'RandomizerGametype'.default.WeaponList.Length)];
    Super.PreBeginPlay();
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    local int i;
    local int w;
    local String WeapLog;
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
        // w = ArrayCount(class'RandomizerGametype'.default.WeaponList);
        w = class'RandomizerGametype'.default.WeaponList.Length;
        for(i=0; i < w; i++)
        {
            
            if(string(Weapon(Other)) != class'RandomizerGametype'.default.WeaponList[i])
            {
                log(string(Weapon(Other)));
            return false;
            }
        }
    }
    else
    {
        return true;
    }
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
