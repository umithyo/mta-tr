function getTeamsType ()
	return get ("*Takım Türü") == "Takım" and "teams" or "scoreboard";
end

addEventHandler ("onResourceStart", root,
	function (res)
		if res == getThisResource () or getResourceName (res) == "mtatr_deathmatches" then
			if getResourceState (getResourceFromName "mtatr_mode") ~= "running" then
                startResource (getResourceFromName "mtatr_mode");
            end
            if getResourceState (getResourceFromName "mtatr_deathmatches") ~= "running" then
                startResource (getResourceFromName "mtatr_deathmatches");
            end
            if getResourceState (getResourceFromName "mtatr_scores") ~= "running" then
                startResource (getResourceFromName "mtatr_scores");
            end
            -- if getResourceState (getResourceFromName "mtatr_jobs") ~= "running" then
                -- startResource (getResourceFromName "mtatr_jobs");
            -- end
            -- exports.mtatr_jobs:buildJobs();
            exports.mtatr_deathmatches:buildDeathmatches();
            exports.mtatr_scores:updateActiveColumns();
		end
	end
);

addEventHandler ("onSettingChange", root,
	function (setting)
		if setting == "*"..getResourceName (getThisResource())..".Takım Türü" then
			restartResource ((getResourceFromName "mtatr_deathmatches"));
			-- restartResource ((getResourceFromName "mtatr_jobs"));
			restartResource ((getResourceFromName "mtatr_teams"));
			-- exports.mtatr_jobs:buildJobs();
			exports.mtatr_deathmatches:buildDeathmatches();
			exports.mtatr_scores:updateActiveColumns();
		end
	end
);
