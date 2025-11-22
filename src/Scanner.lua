-- src/Scanner.lua
-- [[ DEVELOPMENT TOOL ]]
-- This file is currently disabled/empty to keep the mod clean.

-- PURPOSE:
-- The Scanner is used to hunt for unknown function names in the 'game' global table.
-- It wraps candidate functions (like those containing "Fire" or "Weapon") and logs 
-- when they are executed, allowing us to find the "Source of Truth" for player actions.

-- HOW TO RESTORE:
-- If you need to find new mechanics (e.g., a new weapon added in a game patch),
-- refer to previous git commits or the conversation history to restore the 
-- "Targeted Scan" logic here.