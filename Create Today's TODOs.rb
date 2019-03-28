#!/usr/bin/env ruby
# encoding: utf-8

ARGF.set_encoding(Encoding::UTF_8)

def putsStringArray(stringArray)
	stringArray.each_with_index do |line, index|
		# remove the ending newline in the very last string
		if index == stringArray.length - 1
			line.gsub!(/(\r\n|\r|\n)$/, '')
			print line
		else
			puts line
		end
	end
end

lines = Array.new(ARGF.readlines)
linesCopy = Array.new(lines) # stdout the copy if we encounter an error

todaysDate = Time.now.strftime('%F')
todaysTodos = [] << "## #{todaysDate}" << '' << '### TODO' << ''
finishedTodos = []

# Need to keep track of indent level so everything underneath a bullet gets included with it
finishedTodo = false

# Date we're going through
reorderingTodaysTodos = false

# Loop through all the selected lines
lines.each_with_index do |line, idx|
	
	begin
		line =~ /^\s*(\n\r)/
	rescue StandardError => e
		puts "Could not run line-end detection for the following line: "
		puts line
		puts e.message
		puts e.backtrace.inspect
	end
	
	if (idx == 0)
		if line.strip == "## #{todaysDate}"
			reorderingTodaysTodos = true
		else
			finishedTodos << line
		end
	elsif (idx == 1)
		finishedTodos << '' unless reorderingTodaysTodos
	elsif (idx == 2)
		finishedTodos << line unless reorderingTodaysTodos
	elsif (idx == 3)
		finishedTodos << '' unless reorderingTodaysTodos
		
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
			line.gsub!(/\*IN-PROGRESS\*\s+/, '') # remove IN-PROGRESS notice
		else
			finishedTodo = false
		end
		
		if !finishedTodo && !reorderingTodaysTodos
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

# If all Todos rolled over, say so.
if !finishedTodos.last.strip.start_with?("-")
	finishedTodos << "- All rolled over"
end

# Put it in STDOUT
if reorderingTodaysTodos
	putsStringArray(todaysTodos.concat(finishedTodos))
else
	putsStringArray(todaysTodos.push('').concat(finishedTodos))
end