--[[

    Player-specific rate limiter for Roblox. Useful for limiting server remote objects or client UI buttons.

    RateLimiter.new(cooldown: number [, limit: number]) -> RateLimiter

]]

local Players = game:GetService("Players")

local RateLimiter = {}
RateLimiter.__index = RateLimiter

--- @param cooldown number
--- @param limit ?number 
---- Creates a player-specific rate limiter that will check true every `cooldown` seconds since the last passing check
---- Optionally disregards the cooldown if the number of checks is below `limit`
function RateLimiter.new(cooldown, limit)
    assert(cooldown ~= nil, "RateLimiter.new must receive a cooldown")
    assert(type(cooldown) == "number", "RateLimiter cooldown must be a number")
    assert(type(limit) == "number" or type(limit) == "nil", "RateLimiter limit must be a number")

    local rateLimiter = setmetatable({
        _cooldown = cooldown,
        _limit = limit or 1,
        _playerTimestamps = {},
        _playerRequestAmounts = {}
    }, RateLimiter)

    Players.PlayerRemoving:Connect(function(player)
        rateLimiter._playerTimestamps[player] = nil
        rateLimiter._playerRequestAmounts[player] = nil
    end)

    return rateLimiter
end

function RateLimiter:check(player)
    if self._playerTimestamps[player] then
        local diff = time() - self._playerTimestamps[player]
        if diff < self._cooldown then
            if self._playerRequestAmounts[player] >= self._limit then
                return false
            else
                self._playerRequestAmounts[player] += 1
                return true
            end
        else
            self._playerTimestamps[player] = time()
            self._playerRequestAmounts[player] = 1
            return true
        end
    else
        self._playerTimestamps[player] = time()
        self._playerRequestAmounts[player] = 1
        return true
    end
end

return RateLimiter