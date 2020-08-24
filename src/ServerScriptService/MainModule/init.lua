--[[

   _____ _                 _                  _           _       
  / ____(_)               | |        /\      | |         (_)      
 | (___  _ _ __ ___  _ __ | | ___   /  \   __| |_ __ ___  _ _ __  
  \___ \| | '_ ` _ \| '_ \| |/ _ \ / /\ \ / _` | '_ ` _ \| | '_ \ 
  ____) | | | | | | | |_) | |  __// ____ \ (_| | | | | | | | | | |
 |_____/|_|_| |_| |_| .__/|_|\___/_/    \_\__,_|_| |_| |_|_|_| |_|
                    | |                                           
                    |_|                                           

	Hey, I'm Sam! (aka crywink)
	
	I've been a developer on Roblox for a pretty long time now. Since I first opened studio, I remember my first place was just a testing place
	for a popular admin suite called Adonis. It's an extremely extensive script that lets you manage your game from your game with ease. I began
	to start working on the github repo for Adonis, creating pull requests with bug fixes and feature additions. I've finally decided that now, I'm
	at the point where I think I'm ready to take on my own admin system. Lone behold, SimpleAdmin.
	
	The primary goal of SimpleAdmin is, well, to be simple, really. It's supposed to tackle the things that the pre-existing scripts alike failed
	to. This being features like a nice looking UI, while also being easy to customize, configure, and build onto.
	
	This project was also to help me learn more about programming, so I decided to try a bunch of stuff I don't really do often. If
	it seems non-optimal, impractical, or completely broken, let me know and I will fix accordingly.
--]]

return function(Config) -- This function initializes the admin and sets everything in place.
	require(script:WaitForChild("Unpack"))(Config)
	
	return true
end