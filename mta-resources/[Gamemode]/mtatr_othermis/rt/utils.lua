local charset = {}

for i = 65,  90 do table.insert(charset, string.char(i)) end
for i = 97, 122 do table.insert(charset, string.char(i)) end

function generateRandomString(len)
	local str = charset [math.random (#charset)];
	if len > 0 then
		return generateRandomString (len-1)..str;
	else
		return "";
	end
end

local ops = {
	[1] = function (num1, num2)
		local num1, num2 = num1, num2;
		if num1 > 20 then 
			num1 = math.random(20);
		end
		if num2 > 20 then 
			num2 = math.random(20);
		end	
		return num1.." * "..num2, num1*num2;
	end,
	[2] = function (num1, num2, num3)
		return num1.." + "..num2.." - "..num3, num1+num2-num3;
	end,
	[3] = function (num1, num2, num3)
		return num1.." - "..num2.." - "..num3, num1-num2-num3;
	end,
	[4] = function (num1, num2, num3)
		return num1.." - "..num2.." + "..num3, num1-num2+num3;
	end,
	[5] = function (num1, num2, num3)
		return num1.." + "..num2.." + "..num3, num1+num2+num3;
	end,
};

function generateMath()
	local odds = math.random(#ops);
	local num1, num2, num3 = math.random(30), math.random(100), math.random (50);
	return ops[odds](num1, num2, num3);
end