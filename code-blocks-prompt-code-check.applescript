-- Returns the name, extension and type of a file given it's full path.
on getFileInfo(fullPath)
	set ORIGINAL_DELIMITERS to AppleScript's text item delimiters

	-- get file name (including extension)
	set AppleScript's text item delimiters to "/"
	if fullPath contains "/" then
		set fileName to text item -1 of fullPath
	else
		set fileName to fullPath
	end if

	-- get file name and file extension as separate parts
	set AppleScript's text item delimiters to "."
	if fileName contains "." then
		set {nameOnly, fileExtension} to {text 1 thru text item -2, text item -1} of fileName
	else
		set {nameOnly, fileExtension} to {fileName, ""}
	end if

	set AppleScript's text item delimiters to ORIGINAL_DELIMITERS

	-- get default file type
	if fileName is "." & fileExtension then
		set fileType to fileName -- if a dot file then use file name as default file type
	else
		set fileType to fileExtension -- otherwise use file extension as default file type
	end if

	-- get specific file type
	if fileExtension is "js" ¬
	or fileExtension is "jsx" ¬
	or fileExtension is "mjs" ¬
	or fileExtension is "cjs" ¬
	or fileExtension is "mjsx" ¬
	or fileExtension is "cjsx" then
		set fileType to "javascript"

	else if fileExtension is "ts" ¬
	or fileExtension is "tsx" ¬
	or fileExtension is "mts" ¬
	or fileExtension is "cts" ¬
	or fileExtension is "mtsx" ¬
	or fileExtension is "ctsx" then
		set fileType to "typescript"

	else if fileExtension is "htm" ¬
	or fileExtension is "html" then
		set fileType to "html"

	else if fileExtension is "csharp" ¬
	or fileExtension is "cs" then
		set fileType to "cs"

	else if fileExtension is "py" ¬
	or fileExtension is "python" then
		set fileType to "python"

	else if fileExtension is "rs" ¬
	or fileExtension is "rust" then
		set fileType to "rust"

	else if fileExtension is "yml" ¬
	or fileExtension is "yaml" then
		set fileType to "yaml"

	else if fileExtension is "shell" ¬
	or fileExtension is "bash" ¬
	or fileExtension is "zsh" ¬
	or fileExtension is "sh" then
		set fileType to "sh"

	else if fileExtension is "pl" ¬
	or fileExtension is "pm" ¬
	or fileExtension is "perl" then
		set fileType to "perl"

	else if fileExtension is "rb" ¬
	or fileExtension is "ruby" then
		set fileType to "ruby"

	else if fileExtension is "gql" ¬
	or fileExtension is "graphql" then
		set fileType to "graphql"

	else if fileExtension is "md" ¬
	or fileExtension is "markdown" then
		set fileType to "markdown"

	else if fileExtension is "txt" ¬
	or fileExtension is "text" then
		set fileType to "text"

	else if fileExtension is "env" ¬
	or fileName is ".env" ¬
	or nameOnly is ".env" then
		set fileType to "dotenv"

	end if

	return {fileName, fileExtension, fileType}
end getFileInfo



-- Returns a one line comment with the file name (if the file type is recognized).
on getFileNameComment(fileType, fileName)
	if fileType is "c" ¬
	or fileType is "cpp" ¬
	or fileType is "cs" ¬
	or fileType is "java" ¬
	or fileType is "javascript" ¬
	or fileType is "rust" ¬
	or fileType is "scss" ¬
	or fileType is "typescript" then
		set fileNameComment to "// " & fileName

	else if fileType is "css" then
		set fileNameComment to "/* " & fileName & " */"

	else if fileType is "graphql" ¬
	or fileType is "perl" ¬
	or fileType is "python" ¬
	or fileType is "ruby" ¬
	or fileType is "sh" ¬
	or fileType is "yaml" then
		set fileNameComment to "# " & fileName

	else if fileType is "html" then
		set fileNameComment to "<!-- " & fileName & " -->"

	else
		set fileNameComment to ""
	end if

	return fileNameComment
end getFileNameComment



-- Returns the content of a given file as UTF-8.
on getFileContentAsUtf8(fullPath)
	return read POSIX file fullPath as «class utf8»
end getFileContentAsUtf8



-- Finds the shortest delimiter not present in the content.
on generateCodeBlockDelimiter(fileContent)
	set codeBlockDelimiter to "```"

	repeat while fileContent contains codeBlockDelimiter
		set codeBlockDelimiter to codeBlockDelimiter & "`"
	end repeat

	return codeBlockDelimiter
end generateCodeBlockDelimiter



-- Returns code block start delimiter with file type and optional file name comment and extra linefeed.
on generateCodeBlockStart(codeBlockDelimiter, fileType, fileName)
	set codeBlockStart to (codeBlockDelimiter & fileType & linefeed)
	set fileNameComment to getFileNameComment(fileType, fileName)
	if not fileNameComment is "" then
		set codeBlockStart to codeBlockStart & fileNameComment & linefeed
	end if

	return codeBlockStart
end generateCodeBlockStart



-- Returns markdown fenced code block(s) of the specified file(s)
-- and adds a prompt asking to check code for errors and readability.
-- input is expected to be a list of file paths
on run {input, parameters}
	set output to {}

	repeat with fullPath in input
		set {fileName, fileExtension, fileType} to getFileInfo(fullPath)
		set fileContent to getFileContentAsUtf8(fullPath)
		set codeBlockDelimiter to generateCodeBlockDelimiter(fileContent)

		set fencedCodeBlock to ¬
			generateCodeBlockStart(codeBlockDelimiter, fileType, fileName) & linefeed ¬
			& fileContent & linefeed ¬
			& codeBlockDelimiter & linefeed

		set end of output to fencedCodeBlock
	end repeat

	if length of input is 1 then
		set end of output to "Can you check this code for possible errors and also if there is a way to make this code more readable?"
	else if length of input > 1 then
		set end of output to "Can you check these files for possible errors and also if there is a way to make this code more readable?"
	else
		set end of output to "No file provided."
	end if

	set ORIGINAL_DELIMITERS to AppleScript's text item delimiters
	set AppleScript's text item delimiters to linefeed
	set output to output as text
	set AppleScript's text item delimiters to ORIGINAL_DELIMITERS

	return output
end run