-- TextSources.TextSourceRoots.GameClock.SetSetGameSpeed(1)

-- Intentionally disabled. Do not enable without checking the movie callers and multiplayer behavior.
-- Enum 1 means 0.25x speed, not normal speed. Author notes warn that this also delays Lua coroutine resumes.
-- Possible MP exit freeze: the separate speed mod restores enum 3 on leaving the game; these movie scripts install no such guard.
-- Serp recalls testing this during movies: the simulation still appeared to run at normal speed in the background.
-- That recollection is not a new verified test; the command may be ineffective while a movie is playing.
-- The normal companion uses a fixed delay, so its timing relative to the movie must also be checked before re-enabling.
