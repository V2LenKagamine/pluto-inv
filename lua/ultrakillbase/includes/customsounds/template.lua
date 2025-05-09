-- BASE TEMPLATE FOR ULTRAKILLBASE CUSTOM SOUNDS! --


-- How to Add SoundScript for the System play on Spawn! --

-- Format of this function is ID ( String ), AudioPath ( String ), Radius ( Float ), Pitch ( Float ), Volume ( Float ), DieTime ( Float ), Looping ( Boolean ), DopplerFactor ( Float ), TimeScale ( Boolean ) Callback ( Function ) 

	-- ID is the Unique identifier that the code uses to play a specific sound script, --
	-- if you wish to overwrite a certain sound use the same ID and it will be replaced. --

	-- SoundPath is the directory location of the sound file you wish to play. Using a table with this will select a random file out of the table when being played.

	-- Radius is measured in Meters. Having a Radius of 0 means that the 3D Sound Distance is disabled. and the Sound will be played Map Wide --

	-- DieTime is the amount of time the SoundSystem will live, if this is set to nil then it will calculate the duration of the sound it wants to play and use that instead.

	-- Looping, forces the sound to be loop, this can still be used with dietime to make some interesting sfx.

	-- DopplerMultiplier, Higher number means more pronounced doppler effects, lower means less. 0 is no Doppler.

	-- TimeScale enables / disables pitch shifting via game.SetTimeScale()

	-- Callback is a function that will be called every think on the Sound System, the only argument that is being inputted is the System playing the Audio.

	-- I should also mention that like AudioPath. Pitch, and Volume may also use tables to use randomization. but it's a little different.

	-- Pitch tables should have this format { min, max } similar to sound.Add. So let's say i want this sound to randomly pick from 0.2 - 0.5 The way to add this is
	-- { 0.2, 0.5 }, this applies to volume as well. Due note that the randomness is shared between Client and Server for consistency.


-- UltrakillBase.AddSoundScript( "Ultrakill_MinosPrime_ThyEnd", { "ultrakill/voice/Minos/mp_thyend.wav", "ultrakill/voice/Minos/mp_thyend2.wav" }, 0, 1, 1, nil, false, 1, true )












-- How to Add VoiceScripts and Subtitles to a SoundScript --

-- Format of this function is ID ( String ), Priority ( Integer ), Subtitle ( String or Table )

	-- ID, Must be the same as the Above AddSoundScript, inorder for it to also play the subtitles and have proper voice cancelling.

	-- Priority is simple, A voicesound played with an equal or higher number will override the current voicesound. if it's lower than it just doesn't play.

	-- You can also make the Subtitle Arg be a Table.
	-- NOTE. Criteria is Subtitle ( String ), Delay ( Float )
	-- DO NOT NEST DEEPER THAN THIS!

	/*

	{

		{ "A visitor?", 0 },

		{ "Hmm... Indeed, I have slept long enough.", 1.7 },

		{ "The kingdom of heaven has long since forgotten my name", 6.6 },

		{ "And I am EAGER to make them remember", 10.3 },

		{ "However", 15.8 },

		{ "The blood of Minos stains your hands, and I must admit...", 17.2 },

		{ "I'm curious about your skills, Weapon.", 22 },

		{ "And so, before I tear down the cities and CRUSH the armies of heaven...", 25.9 },

		{ "You shall do as an appetizer.", 31.4 },

		{ "Come forth, Child of Man...", 35 },

		{ "And DIE.", 37.4 },

	}

	*/

-- UltrakillBase.AddVoiceSoundScript( "Ultrakill_MinosPrime_ThyEnd", 1, "Thy end is now!" )

-- It's also important to note that anything included via CustomSounds will always overwrite the base sounds. so keep that in mind.

-- To play your sounds use the UltrakillBase.SoundScript() function. It's Arguments are

--	#1, SoundScript ID. The stuff mentioned above.
-- 	#2, Position
-- 	#3, Parent
-- 	#4, Parent Attachment

-- UltrakillBase.SoundScript( "YOUR SOUND ID", Pos, Parent, Attachment )

-- If you set all of this up right, it should play your sound in the game.
-- If you also set up the VoiceSoundScript stuff, it will also add the subtitles and override lines based on priority.
