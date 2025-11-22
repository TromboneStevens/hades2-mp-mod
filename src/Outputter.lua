-- src/Outputter.lua
-- [[ DEVELOPMENT TOOL ]]
-- This file is currently disabled/empty to keep the mod clean.

-- PURPOSE:
-- The Outputter handles writing unique log entries to 'Hades2MP_Log.txt'.
-- It prevents log flooding by storing a history of 'seen' events and only 
-- writing new ones.

-- HOW TO RESTORE:
-- If you need to log data again (e.g., debugging why a specific weapon isn't syncing),
-- restore the file writing logic (return function() ... end) from previous versions.