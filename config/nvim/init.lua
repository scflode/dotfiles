local ok, err = pcall(require, "foshizzle")

if not ok then
   error("Error loading" .. "\n\n" .. err)
end
