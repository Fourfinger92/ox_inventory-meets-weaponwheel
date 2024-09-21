# ox inventory meets weaponwheel

# Big Update: Switching between hotbar and weaponwheel now controllable for users

ox_inventory meets weaponwheel with hotbar controllable via exports for the user

You can find a little demo here: https://youtu.be/hHSZef8WDfU

I made some changes in the files that I provide here to have a weapon wheel, hotbar, or a combination of both controlable via exports. So you can implement them in your own commands or UI. 

Default state is weapon wheel enabled.
# I don't provide an UI or commands to control these features only the exports

Try to replace your files with the file I provide. If needed I can provide you my complete ox_inventory or provide support for implementing my files in your ox_inventory.

There are 3 exports for handling the Hotbar, Weaponwheel, the combination of both and the weapon sync.

exports["ox_inventory"]:weaponWheel()                Switch between hotbar and weapon wheel

exports["ox_inventory"]:Waffensyncdisable()          Disable weaponsync, so you can use temporary weapons that are not in your inventory (for FFA, Gangwar or stuff like this)

exports["ox_inventory"]:WeaponWheelundHotbar()       Switch between hotbar and the combination of both

When you have the combination of weapon wheel an hotbar enabled the keys 1 till 5 will control the hotbar, 6 till 9 and the mouse wheel will control the weapon wheel. Using Tab will trigger both standard functions of hotbar and weapon wheel. So the hotbar UI is visible and the weapon wheel is displayed or the weapon is changed. 


# Example:

exports["ox_inventory"]:weaponWheel(true)

to enable the weapon wheel

exports["ox_inventory"]:weaponWheel(false)

to enable the hotbar after you had the weapon wheel enabled 

exports["ox_inventory"]:Waffensyncdisable(true)

to deactivate the weaponsync (e.g. FFA)

exports["ox_inventory"]:WeaponWheelundHotbar(true)

to enable the combination of hotbar and weapon wheel

exports["ox_inventory"]:WeaponWheelundHotbar(false)

to enable the hotbar after enabling the weapon wheel or the combination of both

# Happy for suggestions, improvements and found bugs :)

Tested with version 2.39.1

All love and appreciation goes to overextended, they are making the best inventory for FiveM out there!

Thanks for the inspiration and help goes to 5Labs https://github.com/5LABS
