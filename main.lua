--- @since 26.9.1
local M = {}

function M:peek(job)
	local file_url = job.file.url
	if job.file.link_to then
		file_url = job.file.link_to
	end

	local child, err = Command("bat")
		:arg({
			"-ppnf", -- style=numbers (overrides -pp's plain), paging=never, force colorization
			"--wrap=never",
			"--tabs=4",
			"--terminal-width",
			tostring(job.area.w),
			tostring(file_url),
		})
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:spawn()

	if not child then
		ya.err("bat.yazi: failed to start `bat`, error: %s", err)
		return M.fallback_to_builtin(job)
	end

	local limit = job.area.h
	local i, lines = 0, {}
	repeat
		local next, event = child:read_line()
		if event == 1 then
			-- stderr (warnings, errors from bat): just consume it, unless stdout
			-- stays empty, which we treat as a failure below.
		elseif event ~= 0 then
			break
		else
			i = i + 1
			if i > job.skip then
				lines[#lines + 1] = next
			end
		end
	until i >= job.skip + limit

	child:start_kill()

	if job.skip > 0 and i < job.skip + limit then
		return ya.emit("peek", {
			math.max(0, i - limit),
			only_if = job.file.url,
			upper_bound = true,
		})
	end

	if #lines == 0 then
		return M.fallback_to_builtin(job)
	end

	-- ANSI codes from bat are parsed into styled text by ui.Text.parse (ansi_to_tui)
	local ok, text = pcall(ui.Text.parse, table.concat(lines))
	if not ok then
		ya.preview_widget(job, { ui.Text(lines):area(job.area) })
	else
		ya.preview_widget(job, { text:area(job.area) })
	end
end

function M:seek(job)
	local h = cx.active.current.hovered
	if h and h.url == job.file.url then
		local step = math.floor(job.units * job.area.h / 10)
		ya.emit("peek", { math.max(0, cx.active.preview.skip + step), only_if = job.file.url })
	end
end

function M.fallback_to_builtin(job)
	local _, bound = ya.preview_code(job)
	if bound then
		ya.emit("peek", { bound, only_if = job.file.url, upper_bound = true })
	end
end

return M
