-- Copyright (c) 2008, Alberto Alonso
--
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without modification,
-- are permitted provided that the following conditions are met:
--
--     * Redistributions of source code must retain the above copyright notice, this
--       list of conditions and the following disclaimer.
--     * Redistributions in binary form must reproduce the above copyright notice, this
--       list of conditions and the following disclaimer in the documentation and/or other
--       materials provided with the distribution.
--     * Neither the name of the superman script nor the names of its contributors may be used
--       to endorse or promote products derived from this software without specific prior
--       written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
-- "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
-- LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
-- A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
-- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
-- EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
-- PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
-- LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
-- NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
local Superman = {}

--[[addEvent ("sp:onLoad", true)
addEventHandler ("sp:onLoad", root, 
	function()
		if exports.tools:isStaff (client) then 
			triggerClientEvent (client, "sp:bind", client)
		end
	end
)	]]--

-- Static global values
local rootElement = getRootElement()
local thisResource = getThisResource()

-- Resource events
addEvent("superman:start", true)
addEvent("superman:stop", true)

--
-- Start/stop functions
--
function Superman.Start()
  local self = Superman

  addEventHandler("superman:start", rootElement, self.clientStart)
  addEventHandler("superman:stop", rootElement, self.clientStop)
  for i, v in ipairs (getElementsByType"player") do 
	if exports.mtatr_accounts:isPlayerInStaff (v) then 
		setElementData (v, "admin", true);
	end
  end	
end
addEventHandler("onResourceStart", getResourceRootElement(thisResource), Superman.Start, false)

function Superman.clientStart()
  setElementData(client, "superman:flying", true)
end

function Superman.clientStop()
  setElementData(client, "superman:flying", false)
end

addEventHandler ("onPlayerLogin", root, 
	function ()
		if exports.mtatr_accounts:isPlayerInStaff (source) then 
			setElementData (source, "admin", true);
		end	
	end
);	