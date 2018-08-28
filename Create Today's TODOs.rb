#!/usr/bin/env ruby

lines = Array.new(ARGF.readlines)
linesCopy = Array.new(lines) # stdout the copy if we encounter an error

todaysDate = Time.now.strftime('%F')
todaysTodos = [] << "## #{todaysDate}" << '' << '### TODO' << ''
finishedTodos = []

# Need to keep track of indent level so everything underneath a bullet gets included with it
finishedTodo = false

# Loop through all the selected lines
lines.each_with_index do |line, idx|
	
	if (idx == 0)
		finishedTodos << line
	elsif (idx == 1)
		finishedTodos << ''
	elsif (idx == 2)
		finishedTodos << line
	elsif (idx == 3)
		finishedTodos << ''
		
#################################################
		
	elsif (line =~ /^\s*(\n\r)/)
		# We are on an empty line
		(finishedTodo ? finishedTodos : todaysTodos) << ''
	elsif (line =~ /^\s+/)
		# We are indented
		(finishedTodo ? finishedTodos : todaysTodos) << line
		
		
#################################################
		
	else
		# Normal line
		
		# Check the start of the line for checkboxes or something else
		if (line =~ /^- \[x\]/i)
			finishedTodo = true
		else
			finishedTodo = false
		end
		
		unless finishedTodo
			if (line =~ /\sROLLOVER/)
				line.gsub!(/\sROLLOVER/, ' ROLLOVER+')
			elsif (line =~ /\*IN-PROGRESS\*/) # Make sure in-progress status precedes rollover status
				line.gsub!(/\*IN-PROGRESS\*/, '*IN-PROGRESS* ROLLOVER')
			else
				line.gsub!(/\[\s*\] /, '[ ] ROLLOVER ')
			end
		end
		(finishedTodo ? finishedTodos : todaysTodos) << line
		
	end
	
end

# Put it in STDOUT
todaysTodos.push('').concat(finishedTodos).each do |line|
	puts line
end
