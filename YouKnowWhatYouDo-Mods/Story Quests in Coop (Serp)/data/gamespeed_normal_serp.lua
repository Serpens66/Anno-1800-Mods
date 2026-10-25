-- TextSources.TextSourceRoots.GameClock.SetSetGameSpeed(3)

-- Intentionally disabled together with gamespeed_slow_serp.lua; do not enable independently.
-- Enum 3 forces 1x speed. It does not restore the speed selected before the movie and may overwrite the player's choice.
-- The companion's enum 1 can delay Lua coroutine resumes; leaving a slower MP game has a reported freeze risk without an exit guard.
-- Serp recalls that the background simulation still ran at normal speed during a movie despite the slowdown attempt.
-- That recollection is not a new verified test; movie-time speed changes may be ineffective.
-- If slowing has no effect, this delayed restore could still change the selected speed later. Movie/delay clock interaction is unverified.
